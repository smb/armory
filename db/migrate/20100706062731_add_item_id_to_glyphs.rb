class AddItemIdToGlyphs < ActiveRecord::Migration
  def self.up
    add_column :glyph_data, :item_id, :integer
  end

  def self.down
    remove_column :glyph_data, :item_id
  end
end
