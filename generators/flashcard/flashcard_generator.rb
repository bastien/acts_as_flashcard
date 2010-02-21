class FlashcardGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template 'add_flashcards_fields_migration.rb', 'db/migrate', :assigns => {
        :migration_name => "AddFlashcardFieldsTo#{table_name}"
      }
      #m.migration_template 'create_flashcards_migration.rb', 'db/migrate', :assigns => {
      #  :migration_name => "Create#{table_name}"
      #}
    end
  end
end