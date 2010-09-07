class RemoveRequestsAndErrorsFromArmoryStats < ActiveRecord::Migration
  def self.up
    remove_column :armory_stats, :requests
    remove_column :armory_stats, :errors
  end

  def self.down
    add_column :armory_stats, :errors, :integer
    add_column :armory_stats, :requests, :integer
  end
end
