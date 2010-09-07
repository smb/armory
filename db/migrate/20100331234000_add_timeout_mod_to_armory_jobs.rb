class AddTimeoutModToArmoryJobs < ActiveRecord::Migration
  def self.up
    add_column :armory_jobs, :timeout_mod, :integer, :default => 0
  end

  def self.down
    remove_column :armory_jobs, :timeout_mod
  end
end
