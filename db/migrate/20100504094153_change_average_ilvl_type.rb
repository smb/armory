class ChangeAverageIlvlType < ActiveRecord::Migration
  def self.up
	change_column :rankings, :average_ilvl, :decimal, :precision => 6, :scale => 2, :default => 0
  end

  def self.down
	change_column :rankings, :average_ilvl, :integer
  end
end
