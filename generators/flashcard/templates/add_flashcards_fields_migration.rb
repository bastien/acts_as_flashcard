class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :successive, :integer, :default => 0
    add_column :<%= table_name %>, :repetitions,  :integer, :default => 0
    add_column :<%= table_name %>, :yes_count,    :integer, :default => 0
    add_column :<%= table_name %>, :no_count,     :integer, :default => 0
    add_column :<%= table_name %>, :factor,       :float,   :default => 2.5
    add_column :<%= table_name %>, :last_factor,  :float,   :default => 2.5
    add_column :<%= table_name %>, :interval,     :integer, :default => 0
    add_column :<%= table_name %>, :last_interval,:float,   :default => 0
    add_column :<%= table_name %>, :due,          :datetime
    add_column :<%= table_name %>, :combined_due, :integer, :default => 0
  end

  def self.down
    remove_column :<%= table_name %>, :successive
    remove_column :<%= table_name %>, :repetitions
    remove_column :<%= table_name %>, :yes_count
    remove_column :<%= table_name %>, :no_count
    remove_column :<%= table_name %>, :factor
    remove_column :<%= table_name %>, :last_factor
    remove_column :<%= table_name %>, :interval
    remove_column :<%= table_name %>, :last_interval
    remove_column :<%= table_name %>, :due
    remove_column :<%= table_name %>, :combined_due
  end
end