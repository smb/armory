class ChangeFormedAtTypeInArenaTeams < ActiveRecord::Migration
  def self.up
	remove_column :arena_teams, :formed_at
  end

  def self.down
	add_column :arena_teams, :formed_at, :integer
  end
end
