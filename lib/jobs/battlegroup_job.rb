require "nokogiri"
require "open-uri"
require "yaml"

class BattlegroupJob < Struct.new(:args)
	def get_url
		return "parse", {:region => args[:region], :page => :battlegroups}
	end
	
	def parse(doc, raw_xml)
		realm_file = File.join(Rails.root, "config", "realms.yml")
		battlegroup_file = File.join(Rails.root, "config", "battlegroups.yml")
		server_file = File.join(Rails.root, "public", "javascripts", "servers.js")
		key_realm_file = File.join(Rails.root, "config", "realm_keys.yml")
		
		begin
			realm_hash = YAML::load(File.open(realm_file).read) || {}
		rescue Exception => e
			realm_hash = {}
		end

		begin
			key_realms = YAML::load(File.open(key_realm_file).read) || {}
		rescue Exception => e
			key_realms = {}
		end
		
		begin
			list = ActiveSupport::JSON.decode(File.open(server_file).read.match(/var servers = (.+)/m)[1]) || []
			autocomplete_list = {}
			list.each do |name|
				autocomplete_list[name.downcase] = name
			end
		rescue Exception => e
			autocomplete_list = {}
		end
				
		begin
			battlegroup_list = YAML::load(File.open(battlegroup_file).read) || {}
		rescue Exception => e
			battlegroup_list = {}
		end
		
		battlegroup_list[args[:region].downcase] = []
		doc.css("battlegroups battlegroup").each do |battlegroup_doc|
			battlegroup_list[args[:region].downcase].push(battlegroup_doc.attr("name"))
				
			battlegroup_doc.css("realms realm").each do |realm_doc|
				realm_hash["#{args[:region]}-#{realm_doc.attr("name")}".downcase] = realm_doc.attr("nameEN") || true
				realm_hash["#{args[:region]}-#{realm_doc.attr("nameEN")}".downcase] = realm_doc.attr("nameEN") || true
				autocomplete_list[realm_doc.attr("name").downcase] = realm_doc.attr("name")
				key_realms["#{args[:region]}:#{realm_doc.attr("nameEN")}".downcase] = args[:region]
			end
		end
		
		key_realms["us:major league gaming"] = "us"
		autocomplete_list["major league gaming"] = "Major League Gaming"
		realm_hash["us:major league gaming"] = "Major League Gaming"
		
		open(realm_file, "w+") do |file|
			file.write(realm_hash.to_yaml)
		end
		
		open(battlegroup_file, "w+") do |file|
			file.write(battlegroup_list.to_yaml)
		end
		
		open(key_realm_file, "w+") do |file|
			file.write(key_realms.to_yaml)
		end

		realm_array = []
		autocomplete_list.each do |id, name|
			realm_array.push(name)
		end

		open(server_file, "w+") do |file|
			file.write("var servers = #{realm_array.to_json}")
		end
	end
end
