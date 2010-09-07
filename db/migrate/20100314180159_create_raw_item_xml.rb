class CreateRawItemXml < ActiveRecord::Migration
  def self.up
	create_table :raw_item_xmls do |t|
		t.integer :item_id
		t.text :item_xml
		t.datetime :created_at
	end

	add_index :raw_item_xmls, :item_id

	create_table :item_reagents do |t|
		t.integer :item_id
		t.integer :reagent_id
		t.integer :quantity
	end

	add_index :item_reagents, :item_id
  end

  def self.down
	drop_table :raw_item_xmls
	drop_table :item_reagents
  end
end
