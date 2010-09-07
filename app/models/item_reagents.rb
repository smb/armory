class ItemReagents < ActiveRecord::Base
	has_one :item, :foreign_key => :item_id, :primary_key => :reagent_id
end
