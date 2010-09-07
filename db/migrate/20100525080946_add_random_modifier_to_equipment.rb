class AddRandomModifierToEquipment < ActiveRecord::Migration
  def self.up
	add_column :equipment, :random_suffix, :integer
  end

  def self.down
	remove_column :equipment, :random_suffix
  end
end
