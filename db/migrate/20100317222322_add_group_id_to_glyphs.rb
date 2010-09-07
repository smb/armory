class AddGroupIdToGlyphs < ActiveRecord::Migration
  def self.up
    add_column :glyphs, :group_id, :integer
	add_index :glyphs, :group_id
	remove_index :glyphs, :talent_id
  end

  def self.down
	add_index :glyphs, :talent_id
    remove_column :glyphs, :group_id
  end
end
