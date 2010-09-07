class RevertIndexing < ActiveRecord::Migration
  def self.up
	add_index :glyphs, :talent_id
	remove_index :glyphs, :group_id
  end

  def self.down
	add_index :glyphs, :group_id
	remove_index :glyphs, :talent_id
  end
end
