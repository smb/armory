class CreateGroupSessionTable < ActiveRecord::Migration
  def self.up
	create_table :group_sessions do |t|
		t.string :session_id
		t.text :queued_hashes
		t.text :character_hashes
		t.text :character_ids
		t.datetime :updated_at
	end
		
	add_index :group_sessions, :session_id
  end

  def self.down
	drop_table :group_sessions
  end
end
