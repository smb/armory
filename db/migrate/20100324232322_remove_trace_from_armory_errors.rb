class RemoveTraceFromArmoryErrors < ActiveRecord::Migration
  def self.up
    remove_column :armory_errors, :trace
  end

  def self.down
	add_column :armory_errors, :trace, :string
  end
end
