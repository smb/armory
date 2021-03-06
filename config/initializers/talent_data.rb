TALENTS = {}
TALENTS[:role_names] = {
	"melee-dps" => "Melee DPS",
	"range-dps" => "Range DPS",
	"caster-dps" => "Caster DPS",
	"tank" => "Tank",
	"healer" => "Healer",
	"unknown" => "Unknown",
}

TALENTS[:archtypes_select] = {
	"All" => "all",
	"Spirit Healer" => "spirit-healer",
	"MP5 Healer" => "mp5-healer",
	"Tank" => "tank",
	"Caster DPS" => "caster-dps",
	"Melee DPS" => "melee-dps",
	"Range DPS" => "range-dps",
}

TALENTS[:base] = {
	"unknown" => {:primary => "unknown", :type => "unknown", :name => "unknown", :icon => "inv_misc_questionmark"},
	
	"arms-warrior" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_rogue_eviscerate"},
	"fury-warrior" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_warrior_innerrage"},
	"prot-warrior" => {:primary => "tank", :type => "physical", :name => "tank", :icon => "ability_warrior_defensivestance"},

	"holy-paladin" => {:primary => "healer", :mp5_healer => true, :type => "caster", :name => "healer", :icon => "spell_holy_holybolt"},
	"prot-paladin" => {:primary => "tank", :type => "physical", :name => "tank", :icon => "spell_holy_devotionaura"},
	"ret-paladin" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "spell_holy_auraoflight"},

	"beast-hunter" => {:primary => "dps", :type => "range", :name => "range-dps", :icon => "ability_hunter_beasttaming"},
	"marks-hunter" => {:primary => "dps", :type => "range", :name => "range-dps", :icon => "ability_marksmanship"},
	"survival-hunter" => {:primary => "dps", :type => "range", :name => "range-dps", :icon => "ability_hunter_swiftstrike"},

	"assass-rogue" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_rogue_eviscerate"},
	"combat-rogue" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_backstab"},
	"subtlety-rogue" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_stealth"},

	"disc-priest" => {:primary => "healer", :type => "caster", :name => "healer", :icon => "spell_holy_wordfortitude"},
	"holy-priest" => {:primary => "healer", :type => "caster", :name => "healer", :icon => "spell_holy_holybolt"},
	"shadow-priest" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_shadow_shadowwordpain"},

	"blood-dk" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "spell_deathknight_bloodpresence"},
	"frost-dk" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "spell_deathknight_frostpresence"},
	"unholy-dk" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "spell_deathknight_unholypresence"},
	"tank-dk" => {:primary => "tank", :type => "physical", :name => "tank", :icon => "inv_shield_61"},

	"elemental-shaman" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_nature_lightning"},
	"enhance-shaman" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "spell_nature_lightningshield"},
	"resto-shaman" => {:primary => "healer", :mp5_healer => true, :type => "caster", :name => "healer", :icon => "spell_nature_magicimmunity"},

	"arcane-mage" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_holy_magicalsentry"},
	"fire-mage" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_fire_flamebolt"},
	"frost-mage" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_frost_frostbolt02"},

	"afflict-warlock" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_shadow_deathcoil"},
	"demon-warlock" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_shadow_metamorphosis"},
	"destro-warlock" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_shadow_rainoffire"},

	"balance-druid" => {:primary => "dps", :type => "caster", :name => "caster-dps", :icon => "spell_nature_lightning"},
	"cat-druid" => {:primary => "dps", :type => "physical", :name => "melee-dps", :icon => "ability_druid_catform"},
	"resto-druid" => {:primary => "healer", :type => "caster", :name => "healer", :icon => "spell_nature_healingtouch"},
	"bear-druid" => {:primary => "tank", :type => "physical", :name => "tank", :icon => "ability_racial_bearform"},
}

TALENTS[:types] = {
	1 => [
		{:type => "arms-warrior", :name => "Arms"}, 
		{:type => "fury-warrior", :name => "Fury"}, 
		{:type => "prot-warrior", :name => "Protection"},
	],
	2 => [
		{:type => "holy-paladin", :name => "Holy"}, 
		{:type => "prot-paladin", :name => "Protection"},
		{:type => "ret-paladin", :name => "Retribution"},
	],
	3 => [
		{:type => "beast-hunter", :name => "Beast Mastery"},
		{:type => "marks-hunter", :name => "Marksmanship"},
		{:type => "survival-hunter", :name => "Survival"},
	],
	4 => [
		{:type => "assass-rogue", :name => "Assassination"},
		{:type => "combat-rogue", :name => "Combat"}, 
		{:type => "subtlety-rogue", :name => "Subtlety"},
	],
	5 => [
		{:type => "disc-priest", :name => "Discipline"},
		{:type => "holy-priest", :name => "Holy"},
		{:type => "shadow-priest", :name => "Shadow"}, 
	],
	6 => [
		{:type => "blood-dk", :name => "Blood"},
		{:type => "frost-dk", :name => "Frost"},
		{:type => "unholy-dk", :name => "Unholy"},
		{:type => "tank-dk", :name => "Tank",
			# These are positions from the compressed data. They MUST BE UPDATED at patch day
			:override_matches => 3,
			:override => {
				3 => 5, # Blade Barrier
				31 => 5, # Toughness
				60 => 5, # Anticipation
			},
		},
	],
	7 => [
		{:type => "elemental-shaman", :name => "Elemental"},
		{:type => "enhance-shaman", :name => "Enhancement"},
		{:type => "resto-shaman", :name => "Restoration"},
	],
	8 => [
		{:type => "arcane-mage", :name => "Arcane"},
		{:type => "fire-mage", :name => "Fire"}, 
		{:type => "frost-mage", :name => "Frost"},
	],
	9 => [
		{:type => "afflict-warlock", :name => "Affliction"},
		{:type => "demon-warlock", :name => "Demonology"},
		{:type => "destro-warlock", :name => "Destruction"},
	],
	11 => [
		{:type => "balance-druid", :name => "Balance"},
		{:type => "cat-druid", :name => "Feral (Cat)"},
		{:type => "resto-druid", :name => "Restoration"},
		{:type => "bear-druid", :name => "Feral (Bear)",
			# These are positions from the compressed data. They MUST BE UPDATED at patch day
			:override_matches => 3,
			:override => {
				33 => 3, # Thick Hide
				35 => 1, # Survival Instincts
				44 => 3, # Natural Reaction
				50 => 3, # Protector of the Pack
			}
		},
	],
}

TALENTS[:bonus] =  {
	1 => {
		1 => {
			:type => "MELEEHIT",
			:pos => 44,
			:percent => 1, # Precision, 1% Hit / Point
						:name => "Precision",
                        :id => [29590,29591,29592],
		},
	},	
	3 => {
		1 => {
			:type => "MELEEHIT",
			:pos => 28,
			:percent => 1, # Focused Aim, 1% Hit / Point
			            :name => "Focused Aim",
                        :id => [53620,53621,53622],
		},
	},				
	4 => {
		1 => {
			:type => "MELEEHITDW",
			:pos => 33,
			:percent => 1, # Precision, 1% Hit / Point
						:name => "Precision",
                        :id => [13705,13832,13843,13844,13845],
		},
	},	
	5 => {
		1 => {
			:type => "SPELLHIT",
			:pos => 61,
			:percent => 1, # Shadow Focus, 1% Hit / Point
                        :name => "Shadow Focus",
                        :id => [15260,15327,15328],
		},
	},
	6 => {
		1 => {
			:type => "MELEEHITDW",
			:pos => 34,
			:percent => 1, # Nerves of Cold Steel, 1% DWHit / Point
						:name => "Nerves of Cold Steel",
                        :id => [49226,50137,50138],
		},
		2 => {
			:type => "SPELLHIT",
			:pos => 59,
			:percent => 1, # Virulence, 1% Spellhit / Point
						:name => "Nerves of Cold Steel",
                        :id => [48962,49567,49568],
		},
	},
	7 => {
		1 => {
			:type => "SPELLHIT",
			:pos => 14,
			:percent => 1, # Elemental Precision, 1% SpellHit / Point
						:name => "Elemental Precision",
                        :id => [30672,30673,30674],
		},
		2 => {
			:type => "MELEEHITDW",
			:pos => 44,
			:percent => 2, # Dual Wield Specialization, 2% Spellhit / Point
						:name => "Dual Wield Specialization",
                        :id => [30816,30818,30819],
		},
	},
	8 => {
		1 => {
			:type => "SPELLHIT",
			:pos => 64,
			:percent => 1, # Precision, 1% SpellHit / Point
						:name => "Precision",
                        :id => [29438,29439,29440],
		},
	},
	9 => {
		1 => {
			:type => "SPELLHIT",
			:pos => 2,
			:percent => 1, # Suppression, 1% SpellHit / Point
						:name => "Suppression",
                        :id => [18174,18175,18176],
			
		},
	},
	11 => {
		1 => {
			:type => "SPELLHIT",
			:pos => 17,
			:percent => 2, # Balance of Power, 2% SpellHit / Point
						:name => "Balance of Power",
                        :id => [33592,33596],
		},
	},
}

TALENTS[:tree_names] = {}
TALENTS[:types].each do |class_id, data|
	data.each do |talent|
		TALENTS[:tree_names][talent[:type]] = talent[:name]
	end
end

# local find = {
   # [GetSpellInfo(57881)] = true, -- Natural Reaction
   # [GetSpellInfo(16929)] = true, -- Thick Hide
   # [GetSpellInfo(61336)] = true, -- Survival Instincts
   # [GetSpellInfo(57877)] = true, -- Protector of the Pack
# }

# local pos = 0
# local compressedTree = ""
# for tab=1, GetNumTalentTabs() do
   # for talent=1, GetNumTalents(tab) do
      # local name, path, tier, column, currentRank, maxRank = GetTalentInfo(tab, talent)
      
      # pos = pos + 1
      # compressedTree = compressedTree .. (currentRank or 0)
      
      # if( find[name] ) then
         # print("Found", name, pos)
      # end
   # end
# end
