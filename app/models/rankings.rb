class Rankings < ActiveRecord::Base
	has_one :character, :class_name => "Character", :foreign_key => :hash_id, :primary_key => :character_hash
	has_one :items, :class_name => "Item", :foreign_key => :item_id, :primary_key => :item_id
	

end


