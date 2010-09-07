class AddItemCurrencyAndCostToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :token_id, :integer
    add_column :items, :token_cost, :integer
  end

  def self.down
    remove_column :items, :token_cost
    remove_column :items, :token_id
  end
end
