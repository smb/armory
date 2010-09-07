class AddIsPvpToTalents < ActiveRecord::Migration
  def self.up
    add_column :talents, :is_pvp, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :talents, :is_pvp
  end
end
