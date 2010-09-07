class AddTeamHashIdToArenaTeams < ActiveRecord::Migration
  def self.up
    add_column :arena_teams, :team_hash, :string
	add_index :arena_teams, :team_hash
	remove_index :arena_teams, :character_id
  end

  def self.down
	remove_index :arena_teams, :team_hash
	add_index :arena_teams, :character_id
    remove_column :arena_teams, :team_hash
  end
end
