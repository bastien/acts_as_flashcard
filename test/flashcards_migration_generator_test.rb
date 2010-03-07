require File.dirname(__FILE__) + '/test_helper.rb'
require 'rails/generators'
require 'generators/flashcard/flashcard_generator'
#require 'rails/generators/scripts/generate'
#require 'rails/generators/scripts/destroy'

class MigrationGeneratorTest < Test::Unit::TestCase
  
  def test_install_flashcard
    
    assert File.exists?(
      File.join(@destination, 'db', 'migrate', 'create_flashcards.rb')
    )
    
    # add some extra test here
  end
  
  def setup
    @destination = File.join('tmp', 'test_app')
    @source = FlashcardGenerator.source_root
  
    FlashcardGenerator.start(["card"], :destination_root => @destination)
  end
  
  def teardown
    FileUtils.rm_rf(@destination)
  end
end