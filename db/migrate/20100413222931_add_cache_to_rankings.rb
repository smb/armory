class AddCacheToRankings < ActiveRecord::Migration
  def self.up
    add_column :rankings, :average_ilvl, :integer, :default => 0
    add_column :rankings, :equip_percent, :decimal, :precision => 3, :scale => 2, :default => 0
    add_column :rankings, :gem_percent, :decimal, :precision => 3, :scale => 2, :default => 0
    add_column :rankings, :enchant_percent, :decimal, :precision => 3, :scale => 2, :default => 0
  end

  def self.down
    remove_column :rankings, :enchant_percent
    remove_column :rankings, :gem_percent
    remove_column :rankings, :equip_percent
    remove_column :rankings, :average_ilvl
  end
end
