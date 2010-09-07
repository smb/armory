class AddRegionToArmoryJobs < ActiveRecord::Migration
  def self.up
    add_column :armory_jobs, :region, :string
  end

  def self.down
    remove_column :armory_jobs, :region
  end
end
