class AddPriorityAndCreateDatIndexes < ActiveRecord::Migration
  def self.up
	add_index :armory_jobs, :priority
	add_index :armory_jobs, :created_at
  end

  def self.down
	remove_index :armory_jobs, :priority
	remove_index :armory_jobs, :created_at
  end
end
