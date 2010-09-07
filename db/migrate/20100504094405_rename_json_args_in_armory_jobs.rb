class RenameJsonArgsInArmoryJobs < ActiveRecord::Migration
  def self.up
	rename_column :armory_jobs, :json_args, :yaml_args
  end

  def self.down
	rename_column :armory_jobs, :yaml_args, :json_args
  end
end
