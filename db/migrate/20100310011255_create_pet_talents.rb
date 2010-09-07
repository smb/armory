class CreatePetTalents < ActiveRecord::Migration
  def self.up
	create_table :pet_talents do |t|
		t.integer :character_id
		t.boolean :active, :null => false
		t.integer :cat_id
		t.integer :group
		t.string :pet_name
		t.string :pet_family_id
		t.string :pet_family_name
		t.string :pet_npc_id
		t.string :pet_npc_name
		t.string :pet_level
		t.string :tree_type
		t.integer :sum_tree1
		t.integer :sum_tree2
		t.integer :sum_tree3
		t.string :compressed_data
	end

	add_index :pet_talents, :character_id
  end

  def self.down
	drop_table :pet_talents
  end
end
