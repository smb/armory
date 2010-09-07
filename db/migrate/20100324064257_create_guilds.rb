class CreateGuilds < ActiveRecord::Migration
  def self.up
	create_table :guilds do |t|
		t.string	:hash_id
		t.string	:region
		t.string	:realm
		t.string	:name
		t.integer	:members
		t.integer	:faction_id
		t.datetime 	:updated_at
	end
	add_index :guilds, :hash_id
  end

  def self.down
	drop_table :guilds
  end
end
