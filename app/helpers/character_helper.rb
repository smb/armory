require "cgi"
module CharacterHelper
	def equip_plural(equipment)
		return equipment.slot_pluralize ? "are" : "is"
	end
	
	def gem_name(name)
		return content_tag(:span, name, :class => name)
	end
	
	def parse_warning(type, warning)
		if type == "jeweler"
			if warning[:found] == 0
				return "Cannot find any of the jewelcrafter only #{link_to ITEMS["JEWELER_GEM"][:name], ResourcedbHelper.link(:item_id => ITEMS["JEWELER_GEM"][:itemid])} gems socketed in equipment, up to #{content_tag(:span, ITEMS["JEWELER_GEM"][:max], :class => "green")} are allowed."
			else
				gem_link = link_to warning[:found] == 1 ? ITEMS["JEWELER_GEM"][:name] : "#{ITEMS["JEWELER_GEM"][:name]}'s", ResourcedbHelper.link(:item_id => ITEMS["JEWELER_GEM"][:itemid])
				return "Found #{content_tag(:span, warning[:found], :class => "red")} of the jewelcrafter only #{gem_link} gems socketed, maximum is #{content_tag(:span, ITEMS["JEWELER_GEM"][:max], :class => "green")}."
			end
		elsif type == "meta"
			reqs = []
			warning.each do |failed|
				if failed[:than]
					reqs.push("more #{gem_name(failed[:more_color])} (#{failed[:more]}) gems than #{gem_name(failed[:than_color])} (#{failed[:than]}) gems")
				elsif failed[:more]
					reqs.push("#{failed[:more]} more #{gem_name(failed[:color])} #{failed[:more] == 1 ? "gem" : "gems"}")
				else
					reqs.push("#{failed[:less]} less #{gem_name(failed[:color])} #{failed[:less] == 1 ? "gem" : "gems"}")
				end
			end
			
			return "Meta gem is not activated, #{reqs.length == 1 ? "need" : "needs:"} #{reqs.join(", ")}."
		end
	end
	
	def char_name(character, title)
	 	link = link_to character.name, ArmoryHelper.build_url(:region => character.region, :page => :character, :r => character.realm, :n => character.name)
		if title.nil? || title[:name].blank?
			return content_tag(:div, link)
		end
				
		title_text = content_tag(:div, title[:name].gsub(", ", "").strip, :class => "title #{small_text(title[:name])}#{title[:location]}")
		name = content_tag(:div, link)
		
		if title[:location] == "prefix"
			return "#{title_text}#{name}"
		else
			return "#{name}#{title_text}"
		end
	end

	def get_portrait(character)
		range = 1
		if character.level >= 80
			range = 80
		elsif character.level >= 70
			range = 70
		elsif character.level >= 60
			range = 60
		end
			
		return "avatars/#{range}/#{character.gender_id}-#{character.race_id}-#{character.class_id}.gif"
	end	

	def fail_text(item, message)
		return "Should not be used by players" if item.spec_type == "never"
		return message % item.spec_name
	end
	
	def small_text(name)
		return "small" if name.mb_chars.length >= 20
	end
	
	def main_tab(character, selected)
		return if character.nil?
		
		classes = "tab"
		classes += " selected" if selected
		
		content_tag(:span,
			content_tag(:span, character.name, :class => "text"),
			:id => character.hash_id,
			:class => classes,
			:onmouseover => tooltip_ajax(api_alt_powered_path(character.region, character.realm, character.name)),
			:onmouseout => tooltip_hide)
	end
		
	def stat_tag(args)
		if args.nil?
			return content_tag(:div, "&nbsp", :class => "fulllabel")
		end
		
		stat = stat_amount(args)
		if stat.blank?
			return content_tag(:div,
				args[:text],
				:class => "fulllabel #{args[:color]}",
				:onmouseover => !args[:tooltip].blank? && tooltip_text(args[:tooltip]),
				:onmouseout => tooltip_hide)
		end
		
		label = content_tag(:div,
			args[:text],
			:class => "label")
		amount = content_tag(:div,
			stat,
			:class => "amount lightbg",
			:onmouseover => !args[:tooltip].blank? && tooltip_text(args[:tooltip]),
			:onmouseout => tooltip_hide)
		return "#{label}#{amount}"
	end
	
	def stat_amount(args)
		if args[:stats]
			tooltip = []
			args[:stats].each do |stat_name, stat|
				if stat.is_a?(Hash) && stat[:percent] > 0
					tooltip.push("#{stat_name}: <span class='statamount'>%.2f%%</span> (<span class='statamount'>%d</span> rating)" % [stat[:percent], stat[:rating]])
				end
			end
			
			args[:tooltip] = tooltip.join("<br />")
		elsif args[:stat]
			args[:amount] = args[:amount] % [args[:stat][:percent] > 0 ? args[:stat][:percent] : args[:stat][:rating]]

			stat = args[:tooltip_stat].nil? ? args[:stat] : args[:tooltip_stat]
			if args[:tooltip].nil? && args[:no_tooltip].nil?
				if args[:is_rating]
					args[:tooltip] = "%s rating: <span class='statamount'>%s</span>" % [args[:tooltip_text] || args[:text], number_with_delimiter(stat[args[:tooltip_type] || :rating])]
				else
					args[:tooltip] = "%s: <span class='statamount'>%s</span>" % [args[:tooltip_text] || args[:text], number_with_delimiter(stat[args[:tooltip_type] || :percent])]
				end
			end
		end
		
		if args[:amount].blank?
			return nil
		elsif args[:tooltip]
			return content_tag(:span,
				number_with_delimiter(args[:amount]),
				{:class => args[:color]})
		else
			return content_tag(:span,
				number_with_delimiter(args[:amount]),
				{:class => args[:color]})
		end
	end
	
	def equipment(character, equipment)
		if !equipment.valid_equip?(character)
			return content_tag(:span,
					"#{image_tag("small-cross.png", :size => "18x18")} #{equipment.item.spec_name}",
					{:onmouseover => tooltip_text("<div class='itemname q#{equipment.item.quality}'>[#{equipment.item.name}]</div>#{fail_text(equipment.item, "%s items are bad for #{character.role_name} specs")}"),
					:onmouseout => tooltip_hide})
		elsif ITEMS["NOTES"][equipment.item_id] and ITEMS["NOTES"][equipment.item_id][:roles].index(character.current_role)
			return content_tag(:span,
					"#{image_tag("icons/inv_misc_note_01.png", :size => "18x18")} #{equipment.item.spec_name}",
					{:onmouseover => tooltip_text("<div class='itemname q#{equipment.item.quality}'>[#{equipment.item.name}]</div>#{ITEMS["NOTES"][equipment.item_id][:message]}"),
					:onmouseout => tooltip_hide})
		elsif !equipment.random_suffix.blank?
			return content_tag(:span,
					"#{image_tag("icons/inv_misc_note_01.png", :size => "18x18")} #{equipment.item.spec_name}",
					{:onmouseover => tooltip_text(ITEMS["NOTES"][:random]),
					:onmouseout => tooltip_hide})
		end
		
		return content_tag(:span,
				"#{image_tag("small-tick.png", :size => "18x18")} #{equipment.item.spec_name}")
	end
	
	def enchant(character, equipment)
		# Check for an extra enchant, eg, extra gems!
		if equipment.extra_enchantable?(character)
			status = equipment.enchant_extra_status(character)
			if status == "socket"
				socket = image_tag("misc/no_enchant.png",
					:size => "24x23",
					:onmouseover => tooltip_text(ITEMS["EXTRA_SOCKETS"][ITEMS["SLOT_TO_ID"][equipment.equipment_id]][:msg]),
					:onmouseout => tooltip_hide)
			else
				data = ITEMS["EXTRA_SOCKETS"][ITEMS["SLOT_TO_ID"][equipment.equipment_id]]
				socket = content_tag(:a,
						image_tag("icons/#{data[:icon]}.png", :size => "24x24"),
						:href => ResourcedbHelper.link(data))
			end
		end
		
		# Cannot use a normal enchant in it :(
		return socket if !equipment.enchantable?(character)
		enchant_data = equipment.spell_enchant || equipment.item_enchant
		enchant_id = enchant_data.is_a?(Item) && enchant_data.item_id || enchant_data.is_a?(Enchant) && enchant_data.enchant_id
		
		status = equipment.enchant_status(character)
		if status == "missing"
			enchant = image_tag("misc/no_enchant.png",
				:class => "pointer",
				:onmouseover => tooltip_text("#{equipment.slot_name} #{equip_plural(equipment)} missing an enchant."),
				:onmouseout => tooltip_hide)
		elsif status == "deathknight"
			enchant = content_tag(:a,
					image_tag("small-cross.png", :size => "24x24"),
					{:href => ResourcedbHelper.link(equipment.item_enchant || equipment.spell_enchant),
					:onmouseover => tooltip_text("Runeforging provides a better enchant than normal weapon enchants for Death Knights."),
					:onmouseout => tooltip_hide})
		elsif status == "spec"
			quality = enchant_data.is_a?(Item) && enchant_data.quality || ITEMS["QUALITY_COMMON"]
			
			enchant = content_tag(:a,
					image_tag("small-cross.png", :size => "24x24"),
					{:href => ResourcedbHelper.link(equipment.item_enchant || equipment.spell_enchant),
					:onmouseover => tooltip_text("<div class='itemname q#{quality}'>[#{enchant_data.name}]</div>#{fail_text(enchant_data, "%s enchants are bad for #{character.role_name} specs.")}"),
					:onmouseout => tooltip_hide})
		elsif ENCHANTS["NOTES"][enchant_id]
			quality = enchant_data.is_a?(Item) && enchant_data.quality || ITEMS["QUALITY_COMMON"]

			return content_tag(:span,
					image_tag("icons/inv_misc_note_01.png", :size => "24x24"),
					{:onmouseover => tooltip_text("<div class='itemname q#{quality}'>[#{enchant_data.name}]</div>#{ENCHANTS["NOTES"][enchant_id]}"),
					:onmouseout => tooltip_hide})
		else
			enchant = content_tag(:a,
					image_tag("icons/#{enchant_data.icon}.png", :size => "24x24"),
					:href => ResourcedbHelper.link(enchant_data))
		end
		
		return "#{enchant}#{socket}"
	end
		
	def gem_list(character, equipment)
		gems = []
		
		for i in 1..equipment.total_sockets
			status = equipment.gem_status(character, i)
			item = equipment.send("item_gem#{i}")
			
			if status == "missing"
				color = equipment.item["gem#{i}_type"]
				gems.push(image_tag("misc/socket-#{color}.png", :size => "25x25",
									:class => "pointer fix",
									:onmouseover => tooltip_text("#{equipment.slot_name} #{equip_plural(equipment)} missing a gem in #{equipment.gem_color_count(color) == 1 ? "the" : "a"} #{color} socket"),
									:onmouseout => tooltip_hide))
			elsif status == "quality"
				gems.push(content_tag(:a,
						image_tag("small-cross.png", :size => "24x24"),
						:href => ResourcedbHelper.link(:item_id => equipment["gem#{i}_id"]),
					:onmouseover => tooltip_text("<div class='itemname q#{item.quality}'>[#{item.name}]</div><span class='q#{equipment.item.quality}'>#{equipment.item.quality_name}</span> equipment should have gems of <span class='q#{item.quality}'>#{item.quality_name.downcase}</span> quality or higher."),
					:onmouseout => tooltip_hide))
			elsif status == "spec"
				gems.push(content_tag(:a,
						image_tag("small-cross.png", :size => "24x24"),
						:href => ResourcedbHelper.link(:item_id => equipment["gem#{i}_id"]),
						:onmouseover => tooltip_text("<div class='itemname q#{item.quality}'>[#{item.name}]</div>#{fail_text(item, "%s gems are bad for #{character.role_name} specs.")}"),
						:onmouseout => tooltip_hide))
			else
				gems.push(content_tag(:a,
							image_tag("icons/#{item.icon}.png", :size => "24x24"),
							:href => ResourcedbHelper.link(:item_id => equipment["gem#{i}_id"])))
			end
		end
		
		return gems.join
	end

	def time_ago(time)
		start_date = Time.new
		seconds_ago = Time.now.to_i - time.to_i
		if seconds_ago < 1.minute
			return "<1 minute ago"
		elsif seconds_ago < 60.minutes
			return pluralize((seconds_ago / 1.minute).round, "minute ago", "minutes ago")
		elsif seconds_ago < 1.day
			return pluralize((seconds_ago / 1.hour).round, "hour ago", "hours ago")
		elsif seconds_ago < 1.week
			return pluralize((seconds_ago / 1.day).round, "day ago", "days ago")
		elsif seconds_ago < 1.month
			return pluralize((seconds_ago / 1.month).round, "month ago", "months ago")
		else
			return "#{time.to_date.to_formatted_s(:db)}"
		end
	end
end