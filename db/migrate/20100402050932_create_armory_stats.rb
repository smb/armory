class CreateArmoryStats < ActiveRecord::Migration
  def self.up
	create_table :armory_stats do |t|
		t.string	:date
		t.string	:region
		t.integer	:requests, :default => 0
		t.integer	:errors, :default => 0
	end
	add_index :armory_stats, :date
  end

  def self.down
	drop_table :armory_stats
  end
end
