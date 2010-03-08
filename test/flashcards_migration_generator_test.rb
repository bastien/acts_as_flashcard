require File.dirname(__FILE__) + '/test_helper.rb'
require 'rails/generators'
require 'generators/flashcard/flashcard_generator'

class MigrationGeneratorTest < Test::Unit::TestCase
  
  def test_install_flashcard
    FlashcardGenerator.start(["some_name_nobody_is_likely_to_ever_use_in_a_real_migration"], :destination_root => @destination)
    new_file = (file_list - @original_files).first
    assert_match /create_flashcards/, new_file
    assert_match /create_table :some_name_nobody_is_likely_to_ever_use_in_a_real_migrations do |t|/, File.read(new_file)
  end
  
  def setup
    @destination = File.join('tmp', 'test_app')
    @source = FlashcardGenerator.source_root
    @original_files = file_list
  end
  
  def teardown
    FileUtils.rm_rf(@destination)
  end
  
  private
    
  def file_list
    Dir.glob(File.join(@destination, "db", "migrate", "*"))
  end
  
end