class RawrController < ApplicationController
	def item
		if params["item_id"].blank? || params["item_id"].to_i == 0
			@error = {:type => "badItemID"}
			render :template => "api/error", :layout => false
			return
		end

		req_error = Armory::Error.find(:first, :conditions => {:numerical_id => params["item_id"], :class_name => ["ItemJob", "ItemIdentifyJob"]}, :order => "created_at ASC")
		if !req_error.nil?
			@error = {:type => req_error[:error_type]}
			render :template => "api/error", :layout => false
			return
		end

		@item = Item.find(:first, :conditions => {:item_id => params["item_id"]}, :include => [:item_sources])
		if @item.nil?
			# If we didn't queue already, put it into the queue and recheck position
			position = Armory::Job.queue_position({:class_name => ["ItemJob", "ItemIdentifyJob"], :numerical_id => params["item_id"]})
			if position == 0
				DataManager.queue_item(:item_id => params["item_id"])
				position = Armory::Job.queue_position({:class_name => ["ItemJob", "ItemIdentifyJob"], :numerical_id => params["item_id"]})
			end
			#position = Armory::Job.exists?({:class_name => ["ItemJob", "ItemIdentifyJob"], :numerical_id => params["item_id"]})
			#if position.nil?
			#	DataManager.queue_item(:item_id => params["item_id"])
			#	position = Armory::Job.exists?({:class_name => ["ItemJob", "ItemIdentifyJob"], :numerical_id => params["item_id"]})
			#end
			
			if !position.nil?
				@queue = {:position => -1, :finished => 0}
				render :template => "api/queue", :layout => false
				return
			else
				@error = {:type => "queueFailure"}
				render :template => "api/error", :layout => false
				return
			end
		end
		
		@raw_xml = RawItemXml.find(:first, :conditions => {:item_id => params["item_id"]})
		render :layout => false
	end
	
	def request_char
		character_hash = Character.get_hash(params["region"], params["realm"], params["name"])
		if character_hash.nil?
			@error = {:type => "noInput"}
			render :template => "api/error", :layout => false
			return
		elsif REALM_DATA["#{params["region"]}-#{params["realm"]}".downcase].nil?
			@error = {:type => "badRealm"}
			render :template => "api/error", :layout => false
			return
		end
		
		queue_char = params["recache"] == "1" ? true : false
		
		# We are not forcing it to recache
		if queue_char.blank?
			# Make sure we have data first, if we don't then requeue
			character = Character.find(:first, :conditions => {:hash_id => character_hash})
			if character.nil? || !character.talents.exists? || !character.equipment.exists?(:group_id => character.active_group)
				queue_char = true
			end
		end
		
		if !queue_char.blank?
			DataManager.queue_character(:character_hash => character_hash, :region => params["region"], :realm => params["realm"], :name => params["name"], :recache => true)
			redirect_to :action => "queue", :realm => params["realm"], :region => params["region"], :name => params["name"]
		else
			Armory::Error.destroy_all(:name_hash => character_hash)
			redirect_to :action => "character", :realm => params["realm"], :region => params["region"], :name => params["name"]
		end
	end
	
	def queue
		if params["region"] == "test" and params["realm"] == "test"
			@error = {:type => params["name"]}
			render :template => "api/error", :layout => false
			return
		end
		
		character_hash = Character.get_hash(params["region"], params["realm"], params["name"])
		if character_hash.nil?
			@error = {:type => "noInput"}
			render :template => "api/error", :layout => false
			return
		elsif REALM_DATA["#{params["region"]}-#{params["realm"]}".downcase].nil?
			@error = {:type => "badRealm"}
			render :template => "api/error", :layout => false
			return
		end
		
		# Check for any errors
		req_error = Armory::Error.find(:first, :conditions => {:name_hash => character_hash, :class_name => ["CharacterJob", "TalentJob"]}, :order => "created_at ASC")
		if !req_error.nil?
			@error = {:type => req_error[:error_type]}
			render :template => "api/error", :layout => false
			return
		end
		
		# Queue position figuring-out, first we need to find out where they are located in the table
		position = Armory::Job.queue_position({:class_name => ["CharacterJob", "TalentJob"], :name_hash => character_hash})
		if position > 0
		#if Armory::Job.exists?({:class_name => ["CharacterJob", "TalentJob"], :name_hash => character_hash})
			@queue = {:position => -1, :finished => 0}
			render :template => "api/queue", :layout => false
			return
		end
		
		# Make sure we have all necessary data
		character = Character.find(:first, :conditions => {:hash_id => character_hash})
		if !character.nil? && character.talents.exists? && character.equipment.exists?(:group_id => character.active_group)
			redirect_to :action => "character", :realm => params["realm"], :region => params["region"], :name => params["name"]
			return
		end
		
		@queue = {:position => -1, :finished => 0}
		render :template => "api/queue", :layout => false
	end
	
	def character
		character_hash = Character.get_hash(params["region"], params["realm"], params["name"])

		req_error = Armory::Error.find(:first, :conditions => {:name_hash => character_hash, :class_name => ["CharacterJob", "TalentJob"]}, :order => "created_at ASC")
		if !req_error.nil?
			@error = {:type => req_error[:error_type]}
			render :template => "api/error", :layout => false
			return
		end
		
		character = Character.find(:first, :conditions => {:hash_id => character_hash})
		if character.nil?
			@error = {:type => "noDBCharacter"}
			render :template => "api/error", :layout => false
			return
		end
		
		@char_data = {:name => character.name, :realm => character.realm, :region => character.region, :race_id => character.race_id, :class_id => character.class_id, :level => character.level}
		
		# Format talents
		talent_group = 1
		@char_data[:talents] = []
		character.talents.all.each do |talent|
			talent_data = {:active => talent.active.blank? ? 0 : 1, :talents => talent.compressed_data, :glyphs => []}
			talent_group = talent.group if !talent.active.blank?
			
			talent.glyphs.all(:conditions => {:character_id => character.id}, :include => :glyph_data).each do |glyph|
				talent_data[:glyphs].push({:type => glyph.glyph_data.is_major.blank? ? "minor" : "major", :name => glyph.glyph_data.name, :id => glyph.glyph_id})
			end
			
			@char_data[:talents].push(talent_data)
		end
		
		# Equipment
		@char_data[:equipment] = []
		character.equipment.all(:conditions => ["group_id = ?", talent_group]).each do |equipment|
			@char_data[:equipment].push({
				:item_id => equipment.item_id, 
				:enchant_id => equipment.enchant_spell,
				:enchant_item_id => equipment.enchant_item,
				:gem1_id => equipment.gem1_id,
				:gem2_id => equipment.gem2_id,
				:gem3_id => equipment.gem3_id,
				:slot => equipment.equipment_id,
			})
		end
		
		# Professions
		@char_data[:professions] = []
		character.professions.all.each do |profession|
			@char_data[:professions].push({:id => profession.profession_id, :current => profession.current})
		end
		
		# Pet talents
		@char_data[:pet_talents] = []
		character.pet_talents.all.each do |talent|
			@char_data[:pet_talents].push({
				:family_id => talent.pet_family_id,
				:name => talent.pet_name,
				:active => talent.active.blank? ? 0 : 1,
				:value => talent.compressed_data,
			})
		end

		render :layout => false
	end	
end