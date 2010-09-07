class AddIndexToARenaCharacters < ActiveRecord::Migration
  def self.up
	add_index :arena_characters, :arena_team_id
  end

  def self.down
	remove_index :arena_characters, :arena_team_id
  end
end
