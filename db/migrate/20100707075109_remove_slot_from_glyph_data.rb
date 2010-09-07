class RemoveSlotFromGlyphData < ActiveRecord::Migration
  def self.up
	remove_column :glyph_data, :slot
  end

  def self.down
  end
end
