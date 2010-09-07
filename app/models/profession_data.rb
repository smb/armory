class ProfessionData < ActiveRecord::Base
	def icon
		if( self.key == "leatherworking" )
			return "icons/inv_misc_armorkit_17.png"
		elsif( self.key == "alchemy" ) 
			return "icons/trade_alchemy.png"
		elsif( self.key == "herbalism" )
			return "icons/trade_herbalism.png"
		elsif( self.key == "tailoring" )
			return "icons/trade_tailoring.png"
		elsif( self.key == "mining" )
			return "icons/trade_mining.png"
		elsif( self.key == "blacksmithing" )
			return "icons/trade_blacksmithing.png"
		elsif( self.key == "engineering" ) 
			return "icons/trade_engineering.png"
		elsif( self.key == "skinning" )
			return "icons/inv_misc_pelt_wolf_01.png"
		elsif( self.key == "enchanting" )
			return "icons/trade_engraving.png"
		elsif( self.key == "inscription" )
			return "icons/inv_inscription_tradeskill01.png"
		elsif( self.key == "jewelcrafting" )
			return "icons/inv_misc_gem_01.png"
		end
	end
end