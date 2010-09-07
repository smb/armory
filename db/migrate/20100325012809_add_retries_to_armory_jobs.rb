class AddRetriesToArmoryJobs < ActiveRecord::Migration
  def self.up
    add_column :armory_jobs, :retries, :integer, :default => 0
  end

  def self.down
    remove_column :armory_jobs, :retries
  end
end
