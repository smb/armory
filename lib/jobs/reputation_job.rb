require "nokogiri"

class ReputationJob < Struct.new(:args)
	def get_url
		return "parse", {:region => args[:region], :page => :reputation, :r => args[:realm], :cn => args[:name]}
	end
	
	def parse(doc, raw_xml)
		ActiveRecord::Base.transaction do 
			@character = Character.find(:first, :conditions => {:hash_id => args[:character_hash]})
			return if @character.nil?
			
			@rep_cache = {}
			@character.reputations.each do |rep|
				@rep_cache[rep.rep_id] = rep
			end
			
			@rep_data = {}
	
			doc.css("reputationTab > faction").each do |reputation|
				@rep_data[reputation.attr("id").to_i] = {:rep_id => reputation.attr("id"), :rep_key => reputation.attr("key"), :name => reputation.attr("name"), :is_header => true}
				
				if reputation.css("faction").length > 0
					recursive_scan(reputation, reputation.attr("iconKey"))
				end
			end
			
			ReputationData.all(:conditions => ["rep_id in (?)", @rep_data.keys]).each do |rep|
				@rep_data.delete(rep.rep_id)
			end
			
			@rep_data.each do |rep_id, rep_data|
				ReputationData.create(rep_data)
			end

			@character.touch
		end
	end
	
	private
	def recursive_scan(doc, parent_key)
		doc.children.each do |reputation|
			next if reputation.attr("name").blank?

			@rep_data[reputation.attr("id").to_i] = {
				:rep_id => reputation.attr("id"),
				:rep_key => reputation.attr("key"),
				:name => reputation.attr("name"),
				:parent_key => parent_key,
				:is_header => reputation.attr("header") == "1" ? true : false}
			
			if !reputation.attr("reputation").nil?
				add_reputation(:id => reputation.attr("id").to_i, :amount => reputation.attr("reputation"))
			end

			if reputation.css("faction").length > 0
				recursive_scan(reputation, reputation.attr("key"))
			end
		end
	end
	
	def add_reputation(args)
		reputation = @rep_cache[args[:id]] || @character.reputations.new
		reputation.rep_id = args[:id]
		reputation.amount = args[:amount]
		reputation.save
	end
end