class DropBattlegroupFromRankandPopulation < ActiveRecord::Migration
  def self.up
	remove_column :rankings, :battlegroup
	remove_column :population_stats, :battlegroup
  end

  def self.down
  end
end
