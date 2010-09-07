class CreateMetaGemData < ActiveRecord::Migration
  def self.up
	create_table :meta_gems do |t|
		t.integer :item_id
		t.text :requirements
	end
	
	add_index :meta_gems, :item_id
  end

  def self.down
	drop_table :meta_gems
  end
end
