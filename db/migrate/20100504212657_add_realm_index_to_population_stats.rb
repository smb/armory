class AddRealmIndexToPopulationStats < ActiveRecord::Migration
  def self.up
	add_index :population_stats, :realm
  end

  def self.down
	remove_index :population_stats, :realm
  end
end
