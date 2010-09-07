class CreateItemStatisticsTable < ActiveRecord::Migration
  def self.up
	create_table :item_statistics do |t|
		t.integer :character_id
		t.integer :character_level
		t.string :spec_role
		t.integer :average_ilvl
		t.integer :equipment_id
		t.integer :socket_color
		t.integer :item_type
		t.integer :item_id, :default => nil
		t.integer :enchant_id, :default => nil
	end
	
	add_index :item_statistics, :character_id
	add_index :item_statistics, :character_level
	add_index :item_statistics, :equipment_id
	add_index :item_statistics, :item_type
	add_index :item_statistics, :item_id
	add_index :item_statistics, :enchant_id
  end

  def self.down
	drop_table :item_statistics
  end
end
