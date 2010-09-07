class AddNameAndGuildHashIndexesToJobs < ActiveRecord::Migration
  def self.up
	add_index :armory_jobs, :name_hash
	add_index :armory_jobs, :guild_hash
  end

  def self.down
	remove_index :armory_jobs, :name_hash
	remove_index :armory_jobs, :guild_hash
  end
end
