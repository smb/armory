class DropIconFromTalents < ActiveRecord::Migration
  def self.up
	remove_column :talents, :icon
  end

  def self.down
  end
end
