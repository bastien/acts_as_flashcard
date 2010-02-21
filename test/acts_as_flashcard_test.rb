require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'

$:.unshift File.dirname(__FILE__) + "/../lib"
require File.dirname(__FILE__) + "/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :flashcards do |t|
      t.column :successive, :integer, :default => 0
      t.column :repetitions, :integer, :default => 0
      t.column :yes_count, :integer, :default => 0
      t.column :no_count, :integer, :default => 0
      t.column :factor, :float, :default => 2.5
      t.column :last_factor, :float, :default => 2.5
      t.column :interval, :integer, :default => 0
      t.column :last_interval, :float, :default => 0
      t.column :due, :datetime
      t.column :combined_due, :integer, :default => 0
      t.column :created_at, :datetime      
      t.column :updated_at, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Flashcard < ActiveRecord::Base
  acts_as_flashcard
end


class ActsAsFlashcardTest < Test::Unit::TestCase
  
  def setup
     setup_db
   end

   def teardown
     teardown_db
   end
  
  # def test_due_date_updated_after_correct_answer
  #   card = Flashcard.create
  #   due_before = card.due
  #   card.answered!(4)
  #   assert (card.due > due_before), true
  # end
  # 
  # def test_factor_should_increase_when_answered_right
  #   card = Flashcard.create(:repetitions => 5)
  #   factor_before = card.factor
  #   card.answered!(4)
  #   assert card.factor, factor_before + 0.10
  # end
  # 
  # def test_factor_should_decrease_when_answered_wrong_if_not_learnt
  #   card = Flashcard.create(:interval => 7.5)
  #   factor_before = card.factor
  #   card.answered!(1)
  #   assert card.factor, factor_before - 0.20
  # end
  # 
  # def test_should_return_the_average_actor
  #   [1,2,3,4,5].each {|i| Flashcard.create(:factor => i)}
  #   card = Flashcard.create
  #   avg = card.__send__(:average_factor)
  #   assert avg, 3
  # end
  # 
  # def test_when_answered_0_no_count_should_increase
  #   card = Flashcard.create(:repetitions => 3, :successive => 2, :no_count => 1, :yes_count => 3)
  #   card.answered!(0)
  #   assert card.repetitions, 4
  #   assert card.successive, 0
  #   assert card.no_count, 2
  #   assert card.yes_count, 3
  # end
  # 
  # def test_when_answered_2_yes_count_should_increase
  #   card = Flashcard.create(:repetitions => 3, :successive => 2, :no_count => 1, :yes_count => 3)
  #   card.answered!(2)
  #   assert card.repetitions, 4
  #   assert card.successive, 3
  #   assert card.no_count, 1
  #   assert card.yes_count, 4
  # end
  # 
  # def test_update_increase_combined_due
  #   card = Flashcard.create()
  #   combined_due_before = card.combined_due
  #   card.answered!(2)
  #   assert card.combined_due > combined_due_before, true
  #   combined_due_before = card.combined_due
  #   card.answered!(4)
  #   assert card.combined_due > combined_due_before, true
  #   combined_due_before = card.combined_due
  #   card.answered!(3)
  #   assert card.combined_due < combined_due_before, true
  #   combined_due_before = card.combined_due
  #   card.answered!(2)
  #   assert card.combined_due < combined_due_before, true
  # end
  # 
  def test_increase_interval_when_right
    card = Flashcard.create()
    card.answered!(2)
    card.answered!(4)
    interval_before = card.interval
    card.answered!(4)
    puts "#{card.interval} > #{interval_before}"
    assert card.interval > interval_before, true
  end
  
  def test_decrease_interval_when_wrong
    card = Flashcard.create()
    card.answered!(2)
    card.answered!(4)
    interval_before = card.interval
    card.answered!(1)
    puts "#{card.interval} > #{interval_before}"
    assert card.interval >= interval_before, true
  end
  
end
