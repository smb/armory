class ItemController < ApplicationController
	def item_tooltip
		return unless stale? :etag => ["item/tooltip", params["item_id"], config_option("version")] 
		@tooltip = Rails.cache.fetch("item/tooltip/#{params["item_id"]}", :raw => true, :expires_in => 1.hour) do
			item = Item.find(:first, :conditions => {:item_id => params["item_id"]})
			if item.nil?
				@tooltip = {:title => "Cannot find item id #{params["item_id"]}"}
			else
				@tooltip = item.get_sources_tooltip
				@tooltip[:data] = render_to_string :partial => "source_tooltip", :tooltip => @tooltip[:data]
			end
			
			@tooltip
		end

		render :layout => false, :template => "layouts/tooltip"
	end
	
	def search
		@total_results, @items = Item.search(:name => params["item"]["name"], :archetype => params["item"]["spec_type"], :limit => 200)
	end
	
	def filter_upgrade
		cookies[:ilvl_band] = {:value => params["band"], :expires => 1.year.from_now}
		cookies[:dungeon_five] = {:value => params["dungeon_five"] == "1" ? 1 : 0, :expires => 1.year.from_now}
		cookies[:dungeon_ten] = {:value => params["dungeon_ten"] == "1" ? 1 : 0, :expires => 1.year.from_now}
		cookies[:dungeon_tf] = {:value => params["dungeon_tf"] == "1" ? 1 : 0, :expires => 1.year.from_now}
		
		if !params["archetype"].blank?
			redirect_to item_filter_path(params["itemid"], params["archetype"])
		else
			redirect_to item_path(params["itemid"])
		end
		return
	end
	
	def item
		if params["item_id"].to_i == 0
			flash[:error] = "No item id found to list upgrades."
			flash[:tab_type] = "upgrade"
			redirect_to root_path
			return
		end
		
		@archetype = !params["archetype"].blank? ? params["archetype"] : nil
		@ilvl_band = cookies[:ilvl_band].to_i == 0 ? config_option("upgrade")["band"] : cookies[:ilvl_band].to_i
		@dungeons = {}
		@dungeons[:fiveman] = cookies[:dungeon_five] == "0" ? nil : 1
		@dungeons[:tenman] = cookies[:dungeon_ten] == "0" ? nil : 1
		@dungeons[:tfman] = cookies[:dungeon_tf] == "0" ? nil : 1
		
		@item = Item.find(:first, :conditions => {:item_id => params["item_id"]}, :order => "level ASC")
		if @item.nil?
			flash[:error] = "Item id ##{params["item_id"]} not found in the database."
			flash[:tab_type] = "upgrade"
			redirect_to root_path
			return
		end
		
		@page_hash = Digest::SHA1.hexdigest("#{@item.cache_key}/#{@archetype}/#{@ilvl_band}/#{@dungeons.to_s}")
		return unless stale? :etag => [@page_hash, current_user, config_option("version")] 
		unless read_fragment(@page_hash, :raw => true, :expires_in => 1.hour)
			@item_sources = @item.get_sources
			@same_items = @item.get_same_type(:archetype => @archetype, :within => @ilvl_band, :dungeons => @dungeons)
			@similar_items = @item.get_similar_type(:archetype => @archetype, :within => @ilvl_band, :dungeons => @dungeons)
			@restrictions = (@item.class_id.blank? ? 0 : 1) + (@item.faction_id.blank? ? 0 : 1)
		end
	end
end