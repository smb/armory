class CreateRankingsTable < ActiveRecord::Migration
  def self.up
	create_table :rankings do |t|
		t.integer	:rank
		t.string	:region
		t.string	:battlegroup
		t.string	:realm
		t.string	:primary_rank
		t.string	:secondary_rank
		t.string	:character_hash
		t.integer	:item_id
	end
	add_index :rankings, :primary_rank
  end

  def self.down
	drop_table :rankings
  end
end
