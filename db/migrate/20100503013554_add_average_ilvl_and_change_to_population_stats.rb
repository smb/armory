class AddAverageIlvlAndChangeToPopulationStats < ActiveRecord::Migration
  def self.up
    add_column :population_stats, :average_ilvl, :decimal, :precision => 6, :scale => 2, :default => 0
    add_column :population_stats, :ilvl_change, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
    remove_column :population_stats, :ilvl_change
    remove_column :population_stats, :average_ilvl
  end
end
