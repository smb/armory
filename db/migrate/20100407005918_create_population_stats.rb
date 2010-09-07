class CreatePopulationStats < ActiveRecord::Migration
  def self.up
	create_table :population_stats do |t|
		t.string	:region
		t.string	:realm
		t.integer	:horde
		t.integer	:alliance
		t.datetime	:updated_at
	end
	add_index :population_stats, :region
  end

  def self.down
	drop_table :population_stats
  end
end
