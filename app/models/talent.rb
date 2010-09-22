class Talent < ActiveRecord::Base
	has_many :glyphs, :dependent => :destroy
	
	def icon
		base = TALENTS[:base][self.spec_role]
		return TALENTS[:base]["unknown"][:icon] if base.nil?
		return base[:icon]
	end
	
	def role_name
		base = TALENTS[:base][self.spec_role]
		return "Unknown" if base.nil?
		return TALENTS[:role_names][base[:name]]
	end
	
	def main_tree
		return "Unknown" if self.spec_role.nil?
		return TALENTS[:tree_names][self.spec_role] || "Unknown"
	end
	
	def get_bonus(class_id, type)
                ret = []
		bonusValue = 0;
		bonus_data = TALENTS[:bonus][class_id]

		if bonus_data
			bonus_data.each do |i, bonus|
				if bonus[:type] == type
					numPoints = self.compressed_data.slice(bonus[:pos] - 1, 1).to_i
					bonusValue = numPoints * bonus[:percent]
                                        #logger.warn "#{type} (pos #{bonus[:pos]} pt) #{numPoints} * bonusPercent: #{bonus[:percent]} = #{bonusValue} (#{self.compressed_data})"
					if !bonus[:name].nil?
						bonus_name = bonus[:name]
                                        else
                                                bonus_name = "unknown"
					end                                        
					if !bonus[:id].nil? and bonus[:id][numPoints]
						bonus_spellid = bonus[:id][numPoints]
					end
                                        if(bonusValue > 0)
                                                ret.push({:percent => bonusValue,:percentSingle => bonus[:percent], :numPoints => numPoints, :name => bonus_name, :id => bonus_spellid})
                                        end
				end
			end
		end

                return ret
        end



	def get_role(class_id)
		talent_data = TALENTS[:types][class_id]
		
		# Check if we have an override
		if talent_data[3]
			matches = 0
			
			talent_data[3][:override].each do |pos, required|
				if( self.compressed_data.slice(pos - 1, 1).to_i >= required )
					matches = matches + 1
				end
			end
			
			if( matches >= talent_data[3][:override_matches] )
				return talent_data[3][:type]
			end
		end

		# Figure out the tree using other magic
		if self.sum_tree1 > self.sum_tree2 and self.sum_tree1 > self.sum_tree3
			return talent_data[0][:type]
		elsif self.sum_tree2 > self.sum_tree1 and self.sum_tree2 > self.sum_tree3
			return talent_data[1][:type]
		elsif self.sum_tree3 > self.sum_tree1 and self.sum_tree3 > self.sum_tree2
			return talent_data[2][:type]
		end
		
		return "unknown"
	end
end
