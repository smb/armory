require "nokogiri"

class GuildSpiderJob < Struct.new(:args)
	PER_BATCH = 250
	
	def get_url
		return "parse", {:page => :guild, :region => args[:region], :r => args[:realm], :gn => args[:name]}
	end
	
	def handle_temporary(code, retries)
		return retries.to_i > 0 && code.to_i == 500 ? "noGuild" : nil
	end
	
	def parse(doc, raw_xml)
		priority = PRIORITIES[:spider_character]
		if !args[:active].blank?
			priority = PRIORITIES[:guild_character]
		end
				
		# <guildHeader battleGroup="Stormstrike" count="19" faction="1" name="Internet Relay Chat" nameUrl="Internet+Relay+Chat" realm="Mal'Ganis" realmUrl="Mal%27Ganis" url="r=Mal%27Ganis&amp;gn=Internet+Relay+Chat"> 
		guild_doc = doc.css("guildHeader")
		
		guild = Guild.find_or_initialize_by_hash_id(args[:guild_hash])
		guild.hash_id = args[:guild_hash]
		guild.members = guild_doc.attr("count").value.to_i
		guild.faction_id = guild_doc.attr("faction").value.to_i
		guild.region = args[:region].downcase
		guild.realm = guild_doc.attr("realm").value
		guild.name = guild_doc.attr("name").value
		guild.touch

		#<character achPoints="40" classId="8" genderId="0" level="19" name="Shale" raceId="10" rank="4" url="r=Mal%27Ganis&amp;cn=Shale"/>
		char_list = {}
		guild_ranks = {}
		
		doc.css("character").each do |character|
			rank = character.attr("rank").to_i
			level = character.attr("level").to_i
			next if level.blank? || rank.blank? || level < 80
			if args[:min] && args[:max]
				next if rank < args[:min].to_i || rank > args[:max].to_i
			end
			
			character_hash = Character.get_hash(args[:region], args[:realm], character.attr("name"))
			
			guild_ranks[rank] ||= []
			guild_ranks[rank].push(character_hash)

			if ( args[:active].blank? || char_list.length < config_option("guildCap") ) && args[:no_queue].blank?
				char_list[character_hash] = {:realm => args[:realm], :region => args[:region], :name => character.attr("name"), :character_hash => character_hash, :guild_hash => args[:guild_hash], :guild_rank => rank, :priority => priority, :recache => args[:recache]}
			end
		end
		
		DataManager.mass_queue_characters(args[:recache], char_list)
		
		# Update ranks of everyone we have data on
		ActiveRecord::Base.transaction do
			# First flag every character in the guild as pending update
			Character.update_all(["guild_rank = ?", -1], ["guild_hash = ?", guild.hash_id])
			
			# Now update the guild rank of everyone we have
			guild_ranks.each do |rank, characters|
				# Do it in batches if it gets too big to prevent possible issues
				if characters.length > PER_BATCH
					(characters.length.to_f / PER_BATCH).ceil.times do |id|
						puts characters.first(PER_BATCH).to_json
						Character.update_all(["guild_rank = ?", rank], ["hash_id IN (?) AND guild_hash = ?", characters.first(PER_BATCH), guild.hash_id])
						characters.slice(0, PER_BATCH)
					end
				else
					Character.update_all(["guild_rank = ?", rank], ["hash_id IN (?) AND guild_hash = ?", characters, guild.hash_id])
				end
			end
			
			# Now, everyone who is still using the temporary -1 rank will be unguilded
			Character.update_all(["guild_rank = ?, guild_hash = ?", nil, nil], ["guild_hash = ? and guild_rank = ?", guild.hash_id, -1])
		end
	end
end