class CreateCharacters < ActiveRecord::Migration
	def self.up
		create_table :characters do |t|
			t.string :hash_id
			t.string :name
			t.string :region
			t.string :realm
			t.string :battlegroup
			t.string :guild
			t.integer :guild_rank
			t.string :guild_hash
			t.string :spec_role
			t.integer :user_id
			t.integer :achievement_points
			t.integer :level
			t.integer :title_id
			t.integer :faction_id
			t.integer :race_id
			t.integer :class_id
			t.integer :gender_id
			t.datetime :updated_at 
		end

		add_index :characters, :hash_id
		
		create_table :character_claims do |t|
			t.string :character_hash
			t.integer :user_id
			t.string :pose_key
			t.string :area
			t.datetime :created_at
		end
		
		create_table :reputations do |t|
			t.integer :character_id
			t.integer :rep_id
			t.integer :amount
		end
		
		add_index :reputations, :character_id
		
		create_table :reputation_data do |t|
			t.integer :rep_id
			t.string :rep_key
			t.string :name
			t.string :parent_key
			t.boolean :is_header, :null => false
		end
		
		add_index :reputation_data, :rep_id
		
		create_table :arena_teams do |t|
			t.string :name
			t.integer :character_id
			t.integer :formed_at
			t.integer :rating
			t.integer :played
			t.integer :won
			t.integer :season_played
			t.integer :season_won
			t.integer :bracket
			t.integer :previous_rank
			t.integer :current_rank
		end
		
		add_index :arena_teams, :character_id
		
		create_table :arena_characters do |t|
			t.integer :arena_team_id
			t.string :character_hash
			t.integer :played
			t.integer :won
			t.integer :season_played
			t.integer :season_won
			t.integer :personal_rating
			t.integer :personal_rank
		end
		
		add_index :arena_characters, :arena_team_id
				
		create_table :glyphs do |t|
			t.integer :glyph_id
			t.integer :talent_id
			t.integer :character_id
		end
		
		add_index :glyphs, :talent_id
		
		create_table :glyph_data do |t|
			t.integer :glyph_id
			t.string :spec_type
			t.string :icon
			t.string :name
			t.string :slot
		end
		
		add_index :glyph_data, :glyph_id
		
		create_table :titles do |t|
			t.integer :title_id
			t.string :name
			t.string :location
		end
		
		add_index :titles, :title_id
		
		create_table :experiences do |t|
			t.integer :character_id
			t.string :child_id
			t.decimal :percent, :precision => 6, :scale => 2
		end
		
		add_index :experiences, :character_id

		create_table :achievements do |t|
			t.integer :character_id
			t.string :child_id
			t.integer :achievement_id
			t.datetime :earned_on
			t.integer :count
		end

		add_index :achievements, :character_id

		create_table :achievement_data do |t|
			t.integer :achievement_id
			t.boolean :is_statistic, :null => false
			t.boolean :is_heroic, :null => false
			t.boolean :is_meta, :null => false
			t.integer :players
			t.string :name
			t.string :icon
		end

		add_index :achievement_data, :achievement_id

		create_table :achievement_criteria do |t|
			t.integer :meta_id
			t.integer :achievement_id
			t.integer :max_quantity
			t.integer :quantity
		end

		add_index :achievement_criteria, :achievement_id

		create_table :professions do |t|
			t.integer :character_id
			t.integer :profession_id
			t.integer :current
			t.integer :max
		end

		add_index :professions, :character_id
		
		create_table :profession_data do |t|
			t.integer :profession_id
			t.string :key
			t.string :name
		end
		
		add_index :profession_data, :profession_id

		create_table :talents do |t|
			t.integer :character_id
			t.boolean :active, :null => false
			t.string :spec_role
			t.string :icon
			t.integer :group
			t.integer :sum_tree1
			t.integer :sum_tree2
			t.integer :sum_tree3
			t.string :compressed_data
		end

		add_index :talents, :character_id

		create_table :stats do |t|
			t.integer :character_id
			t.integer :group_id
			t.string :category
			t.string :stat_type
			t.integer :rating
			t.decimal :percent, :precision => 6, :scale => 2
		end

		add_index :stats, :character_id

		create_table :equipment do |t|
			t.integer :character_id
			t.integer :durability
			t.integer :group_id
			t.integer :equipment_id 
			t.integer :item_id
			t.integer :enchant_spell
			t.integer :enchant_item
			t.integer :gem1_id
			t.integer :gem2_id
			t.integer :gem3_id
		end

		add_index :equipment, :character_id
		
		create_table :enchants do |t|
			t.integer :enchant_id
			t.string :name
			t.string :spec_type
			t.string :icon
		end
		
		add_index :enchants, :enchant_id
		
		create_table :items do |t|
			t.integer :item_id
			t.string :name
			t.integer :quality
			t.integer :level
			t.integer :sockets
			t.integer :slot_id
			t.integer :class_id
			t.integer :faction_id
			t.string :item_type
			t.string :icon
			t.string :set_name
			t.string :spec_type
			t.string :gem1_type
			t.string :gem2_type
			t.string :gem3_type
		end

		add_index :items, :item_id
		
		create_table :item_sources do |t|
			t.integer :item_id
			t.string :name
			t.string :area
			t.string :title
			t.string :source_type
			t.integer :players
			t.integer :npc_id
			t.boolean :is_heroic, :null => false
		end
		
		add_index :item_sources	, :item_id
	end

	def self.down
		drop_table :achievement_criteria
		drop_table :item_sources
		drop_table :arena_characters
		drop_table :arena_teams
		drop_table :reputations
		drop_table :reputation_data
		drop_table :achievement_data
		drop_table :profession_data
		drop_table :experiences
		drop_table :glyph_data
		drop_table :glyphs
		drop_table :characters
		drop_table :achievements
		drop_table :professions
		drop_table :talents
		drop_table :stats
		drop_table :enchants
		drop_table :equipment
		drop_table :titles
		drop_table :items
	end
end











