class AddCacheFieldsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :average_ilvl, :integer, :default => 0
    add_column :characters, :equip_percent, :decimal, :precision => 6, :scale => 3, :default => 0
    add_column :characters, :gem_percent, :decimal, :precision => 6, :scale => 3, :default => 0
    add_column :characters, :enchant_percent, :decimal, :precision => 6, :scale => 3, :default => 0
  end

  def self.down
    remove_column :characters, :enchant_percent
    remove_column :characters, :gem_percent
    remove_column :characters, :equip_percent
    remove_column :characters, :average_ilvl
  end
end
