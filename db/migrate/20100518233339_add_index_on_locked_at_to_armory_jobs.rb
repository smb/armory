class AddIndexOnLockedAtToArmoryJobs < ActiveRecord::Migration
  def self.up
	add_index :armory_jobs, :locked_at
  end

  def self.down
	remove_index :armory_jobs, :locked_at
  end
end
