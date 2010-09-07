class DropCharacterIdFromArena < ActiveRecord::Migration
  def self.up
    remove_column :arena_teams, :character_id
    remove_column :arena_characters, :character_id
	add_index :arena_characters, :character_hash
  end

  def self.down
  end
end
