class AddHashAndIndexesToEnchants < ActiveRecord::Migration
  def self.up
    add_column :enchants, :stat_hash, :string
	add_index :enchants, :stat_hash
	add_index :enchants, :spec_type
  end

  def self.down
  	remove_column :enchants, :stat_hash
	remove_index :enchants, :stat_hash
	remove_index :enchants, :spec_type
  end
end
