class Stat < ActiveRecord::Base
	BASE_ATTRIBS = ["strength", "agility", "stamina", "intellect", "spirit", "armor"]
	DEFENSE_ATTRIBS = ["defense", "armor", "dodge", "parry", "block", "resilience"]
	MELEE_ATTRIBS = ["attackpower", "armorpen", "hit", "expertise", "crit"]
	RANGED_ATTRIBS = ["attackpower", "armorpen", "hit", "crit"]
	SPELL_TYPES = ["arcane", "fire", "frost", "holy", "nature", "shadow"]
end
