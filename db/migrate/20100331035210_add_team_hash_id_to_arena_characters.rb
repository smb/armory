class AddTeamHashIdToArenaCharacters < ActiveRecord::Migration
  def self.up
    add_column :arena_characters, :character_id, :integer
	add_index :arena_characters, :character_id
	remove_index :arena_characters, :arena_team_id
  end

  def self.down
	add_index :arena_characters, :arena_team_id
	remove_index :arena_characters, :character_id
    remove_column :arena_characters, :character_id
  end
end
