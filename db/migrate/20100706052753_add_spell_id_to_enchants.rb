class AddSpellIdToEnchants < ActiveRecord::Migration
  def self.up
    add_column :enchants, :spell_id, :integer
  end

  def self.down
    remove_column :enchants, :spell_id
  end
end
