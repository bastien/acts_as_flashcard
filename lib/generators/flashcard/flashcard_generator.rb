require 'rails/generators'
require 'rails/generators/migration'

class FlashcardGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
  
  def self.next_migration_number(dirname)
    Time.now.strftime("%Y%m%d%H%m%s")
  end
  
  def install_flashcards
    if File.exists?("db/schema.rb") && File.read("db/schema.rb") =~ /create_table \"#{table_name}\"/
      migration_template("add_flashcards_fields_migration.rb","db/migrate/add_flashcards_fields.rb")
    else
      migration_template("create_flashcards_migration.rb","db/migrate/create_flashcards.rb")
    end
  end
  
  
end