require "nokogiri"

class ArenaSpiderJob < Struct.new(:args)
	def get_url
		return "parse", {:page => :arena_team, :ts => args[:bracket], :region => args[:region], :b => args[:battlegroup], :t => args[:team_name], :r => args[:realm]}
	end
	
	def parse(doc, raw_xml)
#        <character battleGroup="Bloodlust" charUrl="r=Blackrock&amp;cn=Hoodrch" class="Warrior" classId="1" contribution="2746" gamesPlayed="0" gamesWon="0" gender="Female" genderId="1" guild="we gettin it in" guildId="18043760" guildUrl="r=Blackrock&amp;gn=we+gettin+it+in" name="Hoodrch" race="Orc" raceId="2" realm="Blackrock" seasonGamesPlayed="123" seasonGamesWon="112" teamRank="0"/>
		doc.css("members character").each do |character|
			# If they arne't in a guild, queue them up right now manually
			# otherwise, the guild spider will grab them, and will have their guild rank too
			if character.attr("guild").blank?
				DataManager.queue_character(:region => args[:region], :realm => args[:realm], :name => character.attr("name"), :character_hash => Character.get_hash(args[:region], args[:realm], character.attr("name")), :priority => PRIORITIES[:spider_character])
			else
				DataManager.queue_guild_spider(:region => args[:region], :realm => args[:realm], :name => character.attr("guild"), :guild_hash => Guild.get_hash(args[:region], args[:realm], character.attr("guild")))
			end
		end
	end
end