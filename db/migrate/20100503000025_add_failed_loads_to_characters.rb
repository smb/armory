class AddFailedLoadsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :failed, :integer
  end

  def self.down
    remove_column :characters, :failed
  end
end
