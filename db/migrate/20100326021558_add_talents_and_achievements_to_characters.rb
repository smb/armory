class AddTalentsAndAchievementsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :has_talents, :boolean
    add_column :characters, :has_achievements, :boolean
  end

  def self.down
    remove_column :characters, :has_achievements
    remove_column :characters, :has_talents
  end
end
