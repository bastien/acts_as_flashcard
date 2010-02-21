$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'acts_as_flashcard'

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::Flashcard
end