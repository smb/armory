class AddBattlegroupToPopulationStats < ActiveRecord::Migration
  def self.up
    add_column :population_stats, :battlegroup, :string
  end

  def self.down
    remove_column :population_stats, :battlegroup
  end
end
