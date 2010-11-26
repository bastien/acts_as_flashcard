class <%= @migration_class_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>" do |t|
      t.column :successive,   :integer, :default => 0
      t.column :repetitions,  :integer, :default => 0
      t.column :yes_count,    :integer, :default => 0
      t.column :no_count,     :integer, :default => 0
      t.column :factor,       :float,   :default => 2.5
      t.column :last_factor,  :float,   :default => 2.5
      t.column :interval,     :integer, :default => 0
      t.column :last_interval,:float,   :default => 0
      t.column :due,          :datetime
      t.column :combined_due, :integer, :default => 0
    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end