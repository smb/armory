class Addequiptype < ActiveRecord::Migration
  def self.up
	add_column :items, :equip_type, :string
  end

  def self.down
	remove_column :items, :equip_type
  end
end
