class AddGuildHashIndex < ActiveRecord::Migration
  def self.up
	add_index :characters, :guild_hash
  end

  def self.down
	remove_index :characters, :guild_hash
  end
end
