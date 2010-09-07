class ChangeGlyphsIndex < ActiveRecord::Migration
  def self.up
	add_index :glyphs, :character_id
	remove_index :glyphs, :talent_id
  end

  def self.down
	add_index :glyphs, :talent_id
	remove_index :glyphs, :character_id
  end
end
