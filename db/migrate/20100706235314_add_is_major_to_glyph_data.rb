class AddIsMajorToGlyphData < ActiveRecord::Migration
  def self.up
    add_column :glyph_data, :is_major, :boolean
  end

  def self.down
    remove_column :glyph_data, :is_major
  end
end
