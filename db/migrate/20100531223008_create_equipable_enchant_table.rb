class CreateEquipableEnchantTable < ActiveRecord::Migration
  def self.up
	create_table :enchant_slots do |t|
		t.integer :item_id
		t.integer :spell_id
		t.integer :equipment_id
	end
	
	add_index :enchant_slots, :item_id
	add_index :enchant_slots, :spell_id
	add_index :enchant_slots, :equipment_id
  end

  def self.down
	drop_table :enchant_slots
  end
end
