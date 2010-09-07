class AddIndexesToItems < ActiveRecord::Migration
  def self.up
	add_index :items, :equip_type
	add_index :items, :item_type
	add_index :items, :slot_id
	add_index :items, :level
	add_index :items, :spec_type
  end

  def self.down
	remove_index :items, :equip_type
	remove_index :items, :item_type
	remove_index :items, :slot_id
	remove_index :items, :level
	remove_index :items, :spec_type
  end
end
