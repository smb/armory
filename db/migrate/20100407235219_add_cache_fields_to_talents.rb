class AddCacheFieldsToTalents < ActiveRecord::Migration
  def self.up
    add_column :talents, :average_ilvl, :integer, :default => 0
    add_column :talents, :equip_percent, :decimal, :precision => 3, :scale => 2, :default => 0
    add_column :talents, :gem_percent, :decimal, :precision => 3, :scale => 2, :default => 0
    add_column :talents, :enchant_percent, :decimal, :precision => 3, :scale => 2, :default => 0
  end

  def self.down
    remove_column :talents, :enchant_percent
    remove_column :talents, :gem_percent
    remove_column :talents, :equip_percent
    remove_column :talents, :average_ilvl
  end
end
