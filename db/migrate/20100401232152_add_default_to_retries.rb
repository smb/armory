class AddDefaultToRetries < ActiveRecord::Migration
  def self.up
    remove_column :armory_jobs, :retries
    add_column :armory_jobs, :retries, :integer, :default => 0
  end

  def self.down
  end
end
