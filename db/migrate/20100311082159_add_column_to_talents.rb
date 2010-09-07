class AddColumnToTalents < ActiveRecord::Migration
  def self.up
    add_column :talents, :unspent, :integer, :default => 0
  end

  def self.down
    remove_column :talents, :unspent
  end
end
