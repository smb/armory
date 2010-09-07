class TrustedNode < ActiveRecord::Migration
  def self.up
	add_column :nodes, :trusted, :boolean, :default => true, :null => false
  end

  def self.down
	remove_column :nodes, :trusted
  end
end
