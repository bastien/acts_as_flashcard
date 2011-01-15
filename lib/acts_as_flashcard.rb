#ActsAsFlashcard
module Flashcard                         #:nodoc:
  module Base                 #:nodoc:
    
    def self.included(base)         #:nodoc:
      base.extend ClassMethods
    end
    
    MAX_SCHEDULE_TIME = 1825
    INITIAL_FACTOR = 2.5
    EASY_INTERVAL_MIN = 7
    EASY_INTERVAL_MAX = 9
    MID_INTERVAL_MIN = 3
    MID_INTERVAL_MAX = 5
    HARD_INTERVAL_MIN = 0.333
    HARD_INTERVAL_MAX = 0.5
    DELAY = 600
    FACTOR_FOUR = 1.3
    
    #  successive    :integer         default(0)
    #  repetitions   :integer         default(0)
    #  yes_count     :integer         default(0)
    #  no_count      :integer         default(0)
    #  factor        :float           default(2.5)
    #  last_factor   :float           default(2.5)
    #  interval      :integer         default(0)
    #  last_interval :float           default(0.0)
    #  due           :datetime
    #  combined_due  :integer         default(0)
    
    module ClassMethods
      
      def acts_as_flashcard(options = {})
        configuration = {:scope => "1 = 1"}
        configuration.update(options) if options.is_a?(Hash)

        configuration[:scope] = "#{configuration[:scope]}_id".to_sym if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

        if configuration[:scope].is_a?(Symbol)
          scope_condition_method = %(
            def scope_condition
              if #{configuration[:scope].to_s}.nil?
                "#{configuration[:scope].to_s} IS NULL"
              else
                "#{configuration[:scope].to_s} = \#{#{configuration[:scope].to_s}}"
              end
            end
          )
        else
          scope_condition_method = "def scope_condition() \"#{configuration[:scope]}\" end"
        end
        
        class_eval <<-EOV
          include Flashcard::Base::InstanceMethods
          
          def acts_as_flashcard_class
            puts "::#{self.name}"
            ::#{self.name}
          end
          
          #{scope_condition_method}
          
          before_create  :initialize_due_date
        EOV
      end
    end
    
    module InstanceMethods
      
      # ease: 0 - 4
      #
      def answered!(ease)
        increment_repetitions(ease)
        last_delay_secs = (Time.now - self.combined_due).to_f
        last_delay    = last_delay_secs / 86400.0
        self.interval = next_interval(ease) unless last_delay >= 0 # keep last interval if reviewing early
        last_due      = self.due
        self.due      = next_due(ease)
        update_factor(ease) if last_delay >= 0
        min_of_other_cards = acts_as_flashcard_class.minimum('interval', :conditions => "#{scope_condition} AND id != #{self.id}")
        space = min_of_other_cards.nil? ? 0 : [min_of_other_cards, self.interval].min
        space = space * 0.1.day
        space = [space, 60].max
        space = Time.now + space
        self.combined_due = [space, due].max
        save
      end
      
      private 
      
      # Set the due date to today when the card is created
      #
      def initialize_due_date
        self.due = Time.now
      end
      
      # Increments the count of time this card has been reviewed,
      # How many times it hasn't been answered wrong successively
      # as well as the amount of time it has been answered right and wrong
      #
      def increment_repetitions(ease)
        self.repetitions += 1
        if ease > 1
          self.successive += 1
        else
          self.successive = 0
        end
        if self.repetitions > 1
          if ease < 2
            self.no_count += 1
          else
            self.yes_count += 1
          end
        end
      end
      
      def delay
        return 0 if repetitions == 0
        if self.combined_due <= Time.now.to_f
          return Time.now - self.due
        else
          return Time.now - self.combined_due
        end
      end

      def next_interval(ease)
        current_delay = delay.to_i
        current_interval = self.interval
        if current_delay < 0 && self.successive > 0
          current_interval = [self.last_interval, self.interval + current_delay].max
          if current_interval < MID_INTERVAL_MIN
            current_interval = 0
          end
          current_delay = 0
        end
        if ease == 1
          current_interval *= DELAY
          current_interval = 0 if current_interval < HARD_INTERVAL_MIN
        elsif current_interval == 0
          case ease
            when 2 then current_interval = rand(HARD_INTERVAL_MAX - HARD_INTERVAL_MIN) + HARD_INTERVAL_MIN
            when 3 then current_interval = rand(MID_INTERVAL_MAX - MID_INTERVAL_MIN) + MID_INTERVAL_MIN
            when 4 then current_interval = rand(EASY_INTERVAL_MAX - EASY_INTERVAL_MIN) + EASY_INTERVAL_MIN
          end
        else
          if current_interval < HARD_INTERVAL_MAX && current_interval > 0.166
            mid = MID_INTERVAL_MIN + MID_INTERVAL_MAX / 2
            current_interval *= (mid / current_interval / self.factor)
            case ease
              when 2 then current_interval = (current_interval + current_delay/4) * 1.2
              when 3 then current_interval = (current_interval + current_delay/2) * self.factor
              when 4 then current_interval = (current_interval + current_delay) * self.factor * FACTOR_FOUR
            end
            fuzz = (rand(10) + 95).to_f / 100.0
            current_interval *= fuzz
          end
        end
        return [MAX_SCHEDULE_TIME, current_interval].min     
      end
      
      # Average factor among all the cards
      #
      def average_factor
        avg_factor =  acts_as_flashcard_class.average("factor", :conditions => "#{scope_condition} AND id != #{self.id}")
        return avg_factor ||= INITIAL_FACTOR
      end

      def update_factor(ease)
        self.last_factor = self.factor
        if repetitions == 0
          self.factor = averageFactor
        end
        if being_learnt? && ([0, 1, 2].include?(ease))
          self.factor -= 0.20 if (self.successive > 0) && (ease != 2)
        else
          case ease
            when 0..1 then self.factor -= 0.20
            when 2 then self.factor -= 0.15
            when 4 then self.factor += 0.10
          end
        end
        self.factor = [1.3, self.factor].max
      end

      def next_due(ease)
        if ease == 1
          return Time.now + DELAY
        else
          return Time.now + self.interval.day
        end
      end

      def being_learnt?
        self.interval < EASY_INTERVAL_MIN
      end
      
    end
    
  end
end

::ActiveRecord::Base.send :include, Flashcard::Base