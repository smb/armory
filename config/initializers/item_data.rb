ITEMS = {
	"QUALITY_POOR" => 0,
	"QUALITY_COMMON" => 1,
	"QUALITY_UNCOMMON" => 2,
	"QUALITY_RARE" => 3,
	"QUALITY_EPIC" => 4,
	"QUALITY_LEGENDARY" => 5,
	"QUALITY_HEIRLOOM" => 7,
}

ITEMS["EQUIP_TYPES"] = {
	:gear => 1,
	:gem => 2,
	:enchant => 3,
}

ITEMS["SOCKET_COLORS"] = {
	"blue" => 0,
	"red" => 1,
	"yellow" => 2,
	"prismatic" => 3,
	"meta" => 4,
}

# This means, any item of epic or higher quality, needs a gem of rare or higher quality
ITEMS["GEM_QUALITIES"] = {
	ITEMS["QUALITY_EPIC"] => ITEMS["QUALITY_RARE"],
	ITEMS["QUALITY_LEGENDARY"] => ITEMS["QUALITY_EPIC"],
}

ITEMS["QUALITIES"] = {
	ITEMS["QUALITY_POOR"] => "Poor",
	ITEMS["QUALITY_COMMON"] => "Common",
	ITEMS["QUALITY_UNCOMMON"] => "Uncommon",
	ITEMS["QUALITY_RARE"] => "Rare",
	ITEMS["QUALITY_EPIC"] => "Epic",
	ITEMS["QUALITY_LEGENDARY"] => "Legendary",
	ITEMS["QUALITY_HEIRLOOM"] => "Heirloom",
}

ITEMS["EXTRA_SOCKETS"] = {
	"belt" => {:item_id => 41611, :icon => "inv_belt_36", :msg => "Missing belt buckle."},
	"hands" => {:spell_id => 55641, :icon => "inv_gauntlets_61", :msg => "Missing additional socket from blacksmithing."},
	"wrist" => {:spell_id => 55628, :icon => "inv_jewelcrafting_thoriumsetting", :msg => "Missing additional socket from blacksmithing."},
}

ITEMS["GEM_BASE"] = ["red", "blue", "yellow"]
ITEMS["GEM_COLORS"] = {
	"prismatic" => ["red", "blue", "yellow"],
	"purple" => ["red", "blue"],
	"orange" => ["red", "yellow"],
	"green" => ["blue", "yellow"],
}

# 350 = Dragon's Eye
# 500 = Chimera's Eye
ITEMS["JEWELER_ICON"] = ["inv_jewelcrafting_dragonseye0[2-9]"]
ITEMS["MAX_JEWELER_GEMS"] = 3
ITEMS["JEWELER_GEM"] = {:max => 3, :name => "Dragon's Eye", :itemid => 42225}

ITEMS["PVP_TYPES"] = ["pvp", "pvp/sta"]
ITEMS["NAMES"] = {
	"all" => "All",
	"unknown" => "Unknown",
	"never" => "Never",
	"pvp" => "PVP",
	"pvp/sta" => "PVP/Stamina",
	"physical-all" => "Physical, All",
	"physical-dps" => "Physical, DPS",
	"melee" => "Melee, All",
	"melee-dps" => "Melee, DPS",
	"tank" => "Tank",
	"resist" => "Resistance",
	"tank/dps" => "Tank/DPS",
	"dps" => "DPS",
	"healer" => "Healer",
	"healer/dps" => "Healer/DPS",
	"spirit/cloak" => "Caster, Spirit",
	"caster" => "Casters, All",
	"caster-dps" => "Caster, DPS",
	"caster-spirit" => "Caster, Spirit",
	"paladin" => "Paladin",
	"tank/range" => "Tank/Hunter",
	"range-dps" => "Hunter",
	"random" => "Random suffix",
	"attackpower" => "Attack power",
}

ITEMS["SIMILAR_TYPES"] = {
	"caster" => ["caster-dps", "caster-spirit"],
	"caster-dps" => ["caster", "caster-spirit", "tank/dps", "dps"],
	"caster-spirit" => ["caster", "spirit/cloak"],
	"tank" => ["melee", "tank/dps"],
	"melee" => ["physical-all", "tank/dps", "physical-dps"],
	"physical-dps" => ["physical-all", "dps", "tank/dps"],
	"melee-dps" => ["physical-all", "dps", "tank/dps", "physical-dps"],
	"range-dps" => ["physical-all", "dps", "tank/dps"],

	# These are used by archetype filters only
	"spirit-healer" => ["caster", "caster-spirit", "healer", "healer/dps", "spirit/cloak"],
	"mp5-healer" => ["caster", "healer", "healer/dps"],
}

ITEMS["ILVL_MODS"] = {
	ITEMS["QUALITY_POOR"] => 0.50,
	ITEMS["QUALITY_COMMON"] => 0.60,
	ITEMS["QUALITY_UNCOMMON"] => 0.90,
	ITEMS["QUALITY_RARE"] => 0.95,
	ITEMS["QUALITY_EPIC"] => 1,
}

# Item level of heirlooms based on the player's level. Currently this is ~2.22/per player level, meaning they work out to 187 item level blues at 80
# with the quality modifier they are item level ~177
# This will have to change come Cataclysm, not quite sure how Blizzard is going to handle heirlooms then
ITEMS["HEIRLOOM_LEVEL"] = 187 / 80

ITEMS["ORDERED_SLOTS"] = [0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]

# Blizzard does not use the standard in-game slot ids
# We do not pluralize rings because one ring has an enchant, not both
ITEMS["SLOT_PLURALIZE"] = {
	2 => true, # Shoulders
	6 => true, # Pants
	8 => true, # Wrists
	7 => true, # Boots
	9 => true, # Hands
}

ITEMS["SLOT_TO_ID"] = {
	0 => "head",
	1 => "neck",
	2 => "shoulders",
	#3 => "shirt",
	4 => "chest",
	5 => "belt",
	6 => "pants",
	7 => "boots",
	8 => "wrist",
	9 => "hands",
	10 => "ring1",
	11 => "ring2",
	12 => "trinket1",
	13 => "trinket2",
	14 => "cloak",
	15 => "mainhand",
	16 => "offhand",
	17 => "range",
	#18 => "tabard",
}

ITEMS["SLOT_TO_TYPE"] = {
	0 => "head",
	1 => "neck",
	2 => "shoulders",
	4 => "chest",
	5 => "belt",
	6 => "pants",
	7 => "boots",
	8 => "wrists",
	9 => "hands",
	10 => "ring",
	11 => "ring",
	12 => "trinket",
	13 => "trinket",
	14 => "cloak",
	15 => "weapon",
	16 => "weapon",
	17 => "range",
}

# Map of Blizzard inventory ids to our types
ITEMS["INV_TYPE_TO_TYPE"] = {
	1 => ITEMS["SLOT_TO_TYPE"][0], # Head
	2 => ITEMS["SLOT_TO_TYPE"][1], # Neck
	3 => ITEMS["SLOT_TO_TYPE"][2], # Shouldes
	5 => ITEMS["SLOT_TO_TYPE"][4], # Chest
	6 => ITEMS["SLOT_TO_TYPE"][5], # Belt
	7 => ITEMS["SLOT_TO_TYPE"][6], # Pants
	8 => ITEMS["SLOT_TO_TYPE"][7], # Boots
 	9 => ITEMS["SLOT_TO_TYPE"][8], # Wrists
	10 => ITEMS["SLOT_TO_TYPE"][9], # Hands
	11 => ITEMS["SLOT_TO_TYPE"][10], # Ring 
	12 => ITEMS["SLOT_TO_TYPE"][12], # Trinket
	13 => ITEMS["SLOT_TO_TYPE"][15], # One-hand (Weapon)
	14 => ITEMS["SLOT_TO_TYPE"][15], # Off-hand (Weapon)
	15 => ITEMS["SLOT_TO_TYPE"][17], # Range
	16 => ITEMS["SLOT_TO_TYPE"][14], # Cloak
	17 => ITEMS["SLOT_TO_TYPE"][15], # Two-hand (Weapon)
	20 => ITEMS["SLOT_TO_TYPE"][4], # Chest (Same as #5?)
	21 => ITEMS["SLOT_TO_TYPE"][15], # Main-hand (Weapon)
	22 => ITEMS["SLOT_TO_TYPE"][15], # Off-hand (Weapon)
	23 => ITEMS["SLOT_TO_TYPE"][15], # Off-hand only (Weapon)
	25 => ITEMS["SLOT_TO_TYPE"][17], # Thrown
	26 => ITEMS["SLOT_TO_TYPE"][17], # Ranged (Same as #15?)
	28 => "relic", # Relic
}

# These are generic equipment ids, 
ITEMS["EQUIP_ID_NAMES"] = {
	0 => "Helm",
	1 => "Neck",
	2 => "Shoulders",
	4 => "Chest",
	5 => "Waist",
	6 => "Legs",
	7 => "Boots",
	8 => "Wrists",
	9 => "Gloves",
	10 => "Ring 1",
	11 => "Ring 2",
	12 => "Trinket 1",
	13 => "Trinket 2",
	14 => "Cloak",
	15 => "Main hand",
	16 => "Offhand",
	17 => "Range",
}

ITEMS["SLOT_ID_NAMES"] = {
	13 => "Weapon", # One-hand
	14 => "Shield", # Shield
	15 => "Range", # Range
	17 => "2H-Weapon", # Two-hand
	21 => "Main hand", # Main-hand
	22 => "Offhand", # Off-hand
	23 => "Offhand", # Off-hand only
	25 => "Thrown", # Thrown
	26 => "Range", # Ranged (Same as #15?)
	28 => "Relic", # Relic
}

ITEMS["TYPE_BLACKLIST"] = ["random"]

# Set what specs can use what item types
tank = {"random" => true, "all" => true, "tank" => true, "melee" => true, "physical-all" => true, "tank/dps" => true, "tank/range" => true, "tank/pvp" => true, "resist" => true}
caster_damage = {"random" => true, "all" => true, "caster-spirit" => true, "caster-dps" => true, "caster" => true, "healer/dps" => true, "tank/dps" => true, "dps" => true, "spirit/cloak" => true}
melee_damage = {"random" => true, "all" => true, "melee" => true, "melee-dps" => true, "physical-dps" => true, "physical-all" => true, "tank/dps" => true, "healer/dps" => true, "dps" => true}
range_damage = {"random" => true, "all" => true, "range-dps" => true, "tank/range" => true, "physical-dps" => true, "physical-all" => true, "healer/dps" => true, "tank/dps" => true, "dps" => true}
healer = {"random" => true, "all" => true, "healer" => true, "caster" => true, "healer/dps" => true, "situational-healer" => true}

ap_melee_damage = melee_damage.merge("attackpower" => true)
spirit_healer = healer.merge("caster-spirit" => true, "spirit/cloak" => true)

ITEMS["TALENT_ROLES"] = {
	# Shamans
	"elemental-shaman" => caster_damage.merge("pvp/sta" => true),
	"enhance-shaman" => ap_melee_damage,
	"resto-shaman" => healer.merge("pvp/sta" => true, "spirit/cloak" => true),
	# Mages
	"arcane-mage" => caster_damage,
	"fire-mage" => caster_damage,
	"frost-mage" => caster_damage,
	# Warlocks
	"afflict-warlock" => caster_damage,
	"demon-warlock" => caster_damage,
	"destro-warlock" => caster_damage,
	# Druids
	"balance-druid" => caster_damage.merge("manaless" => true, "pvp/sta" => true),
	"cat-druid" => melee_damage,
	"bear-druid" => melee_damage.merge(tank).merge("pvp" => true),
	"resto-druid" => spirit_healer.merge("manaless" => true, "pvp/sta" => true),
	# Warriors
	"arms-warrior" => melee_damage,
	"fury-warrior" => melee_damage,
	"prot-warrior" => tank.merge("tank/range" => true),
	# Rogues
	"assass-rogue" => ap_melee_damage,
	"combat-rogue" => ap_melee_damage,
	"subtlety-rogue" => ap_melee_damage,
	# Paladins
	"holy-paladin" => healer.merge("paladin" => true),
	"prot-paladin" => tank,
	"ret-paladin" => melee_damage,
	# Hunters
	"beast-hunter" => range_damage.merge("tank/range" => true, "attackpower" => true),
	"marks-hunter" => range_damage.merge("tank/range" => true, "attackpower" => true),
	"survival-hunter" => range_damage.merge("tank/range" => true, "attackpower" => true),
	# Priests
	"disc-priest" => spirit_healer.merge("manaless" => true),
	"holy-priest" => spirit_healer.merge("manaless" => true),
	"shadow-priest" => caster_damage.merge("pvp/sta" => true),
	# Death Knights
	"blood-dk" => melee_damage,
	"frost-dk" => melee_damage,
	"unholy-dk" => melee_damage,
	"tank-dk" => tank,
}

ITEMS["RELIC_SPELLS"] = {
	# DRUID
	"Insect Swarm" => "caster-dps",
	"Moonfire" => "caster-dps",
	"Starfire" => "caster-dps",
	"Wrath" => "caster-dps",
	"Maul" => "feral-tank",
	"Swipe" => "tank/dps",
	"Mangle" => "tank/dps",
	"Rip " => "melee-dps", # The space stops this from matching Riptide
	"Shred" => "melee-dps",
	"Rejuvenation" => "healer",
	"Regrowth" => "healer",
	"Lifebloom" => "healer",
	"Wild Growth" => "healer",
	"Nourish" => "healer",
	"Healing Touch" => "healer",
	# PALADIN
	"Holy Light" => "healer",
	"Flash of Light" => "healer",
	"Holy Shock" => "healer",
	"Crusader Strike" => "melee-dps",
	"Divine Storm" => "melee-dps",
	"Shield of Righteousness" => "tank",
	"Hammer of the Righteous" => "tank",
	"Seal of Vengeance" => "tank",
	"Seal of Corruption" => "tank",
	"Holy Shield" => "tank",
	"Consecration" => "tank/dps",
	# SHAMAN
	"Riptide" => "healer",
	"Chain Heal" => "healer",
	"Healing Wave" => "healer",
	"Lesser Healing Wave" => "healer",
	"Flame Shock" => "caster-dps",
	"Stormstrike" => "melee-dps",
	"Lava Lash" => "melee-dps",
	"Lightning Bolt" => "caster-dps",
	"Chain Lightning" => "caster-dps",
	"Lava Burst" => "caster-dps",
	"Storm Strike" => "melee-dps",
	"Windfury Weapon" => "melee-dps",
	#"Shock spells" => "caster-dps",
	# DEATH KNIGHT
	"Rune Strike" => "tank",
	"Blood Strike" => "melee-dps",
	"Heart Strike" => "melee-dps",
	"Icy Touch" => "melee-dps",
	"Plague Strike" => "melee-dps",
	"Obliterate" => "melee-dps",
	"Death Strike" => "melee-dps",
	"Death Coil" => "melee-dps",
	"Scourge Strike" => "melee-dps",
}

# This is separate because I don't want enchants or gems to accidentally hit these
ITEMS["TRINKET_TEXTS"] = {
	"HELPFUL_SPELL" => "helpful spell",
	"HARMFUL_SPELL" => "harmful spell",
	"PERIODIC_DAMAGE" => "periodic damage",
	"MELEE_ATTACK" => "chance on melee attack",
	"CHANCE_MELEE_OR_RANGE" => "chance on melee or range",
	"CHANCE_MELEE_AND_RANGE" => "chance on melee and range",
	"RANGED_CRITICAL_STRIKE" => "ranged critical",
	"MELEE_OR_RANGE" => "melee or range",
	"SPELL_DAMAGE" => "spell damage",
	"MELEE_AND_RANGE" => "melee and ranged",
	"DEAL_DAMAGE" => "deal damage",
	"ARMOR_BY" => "armor by",
	"ARMOR_FOR" => "armor for",
	"WHEN_HIT" => "when hit",
}

ITEMS["STATS"] = {
	"mana" => "MANA",
	"health" => "HEALTH",
	"all stats" => "STAT_ALL",
	"stamina" => "STAMINA",
	"armor penetration" => "ARMOR_PENETRATION",
	"agility" => "AGILITY",
	"armor" => "ARMOR",
	"attack power" => "ATTACK_POWER",
	"critical strike" => "CRIT",
	"crit strike" => "CRIT",
	"resilience rating" => "RESILIENCE",
	"parry rating" => "PARRY",
	"hit rating" => "HIT",
	"block rating" => "BLOCK",
	"block value" => "BLOCK",
	"defense rating" => "DEFENSE",
	"dodge rating" => "DODGE",
	"expertise rating" => "EXPERTISE",
	"haste rating" => "HASTE",
	"intellect" => "INTELLECT",
	"mana per 5 sec" => "MANA_REGEN",
	"spell penetration" => "SPELL_PENETRATION",
	"spell power" => "SPELL_POWER",
	"spirit" => "SPIRIT",
	"strength" => "STRENGTH",
	"root duration" => "ROOT_DURATION",
	"silence duration" => "SILENCE_DURATION",
	"stun resistance" => "STUN_RESISTANCE",
	"fear duration" => "FEAR_DURATION",
	"stun duration" => "STUN_RESISTANCE",
	"run speed" => "RUN_SPEED",
	"minor movement speed" => "RUN_SPEED",
	"mana every 5 sec" => "MANA_REGEN",
}

# Some stats when doing a trinket scan for stats have to be ignored, because they can cause conflicts. Such as armor/armor penentration
ITEMS["IGNORE_ON_SEARCH"] = {
}

ITEMS["ARMOR_MAP"] = {
	"bonusAgility" => "AGILITY",
	"bonusStamina" => "STAMINA",
	"armor" => "ARMOR",
	"bonusAttackPower" => "ATTACK_POWER",
	"bonusCritRating" => "CRIT",
	"bonusExpertiseRating" => "EXPERTISE",
	"bonusStrength" => "STRENGTH",
	"bonusDefenseSkillRating" => "DEFENSE",
	"bonusDodgeRating" => "DODGE",
	"bonusHasteRating" => "HASTE",
	"bonusArmorPenetration" => "ARMOR_PENETRATION",
	"bonusHitRating" => "HIT",
	"bonusParryRating" => "PARRY",
	"bonusResilienceRating" => "RESILIENCE",
	"bonusSpellPenetration" => "SPELL_PENETRATION",
	"bonusIntellect" => "INTELLECT",
	"bonusSpirit" => "SPIRIT",
	"bonusSpellPower" => "SPELL_POWER",
	"bonusManaRegen" => "MANA_REGEN",
	"bonusBlockRating" => "BLOCK",
	"bonusBlockValue" => "BLOCK",
	"arcaneResist" => "ARCANE_RESIST",
	"frostResist" => "FROST_RESIST",
	"shadowResist" => "SHADOW_RESIST",
	"fireResist" => "FIRE_RESIST",
	"natureResist" => "NATURE_RESIST",
}

#slotbak:21,displayid:64649,reqlevel:80,maxcount:1,dmgmin1:142,dmgmax1:414,dmgtype1:0,speed:1.80,socket1:8,feratkpwr:1395,critstrkrtng:50,splpwr:836,sta:75,int:75,spi:66,dura:75,dps:154.4,nsockets:1,mledps:154.4,mledmgmin:142,mledmgmax:414,mlespeed:1.80
#Stored in jsonEquip
ITEMS["WOWHEAD_MAP"] = {
	"critstrkrtng" => "CRIT",
	"splpwr" => "SPELL_POWER",
	"sta" => "STAMINA",
	"int" => "INTELLECT",
	"spi" => "SPIRIT",
	"agi" => "AGILITY",
	"defrtng" => "DEFENSE",
	"blockrtng" => "BLOCK",
	"parryrtng" => "PARRY",
	"block" => "BLOCK",
	"atkpwr" => "ATTACK_POWER",
	"resirtng" => "RESILIENCE",
	"hastertng" => "HASTE",
	"manargn" => "MANA_REGEN",
	"armor" => "ARMOR",
	"manargn" => "MANA_REGEN",
	"exprtng" => "EXPERTISE",
	"armorpenrtng" => "ARMOR_PENETRATION",
	"splpen" => "SPELL_PENETRATION",
	"dodgertng" => "DODGE",
	"hitrtng" => "HIT",
	"firres" => "FIRE_RESIST",
	"arcres" => "ARCANE_RESIST",
	"shares" => "SHADOW_RESIST",
	"natres" => "NATURE_RESIST",
	"frores" => "FROST_RESIST",

}

# Override for specific enchants
ENCHANTS = {}
ENCHANTS["OVERRIDES"] = {
	3878 => "tank", # Mind Amplification Dish, it is higher STA than the other one, going for the safe flagging for now. Perhaps flag as never?
	3604 => "healer/dps", # Hyperspeed Accelerators
	3606 => "all", # Nitro Boosts
	3860 => "tank", # Reticulated Armor Webbing
	3859 => "caster", # Springy Arachnoweave
	3605 => "physical-all", # Flexweave Underlay
	3728 => "caster", # Darkglow Embroidery
	3730 => "physical-dps", # Swordguard Embroidery
	3722 => "caster", # Lightweave Embroidery
	3367 => "pvp", # Rune of Spellshattering
	3595 => "pvp", # Rune of Spellbreaking
	3366 => "never", # Rune of Lichbane
	3369 => "physical-dps", # Rune of Cinderglacier
	3370 => "physical-dps", # Rune of Razorice
	3594 => "tank/pvp", # Rune of Swordbreaking
	3365 => "tank/pvp", # Rune of Swordshattering
}

ENCHANTS["NOTES"] = {
	3594 => "Situational enchant, can be better Rune of the Nerubian Carapace in some scenarios.",
	3365 => "Situational enchant, can be better Rune of the Stoneskin Gargoyle in some scenarios.",
}

GLYPHS = {}
GLYPHS["REMAP"] = {
	480 => "Glyph of Exhaustion",
	227 => "Glyph of Mana Tide Totem",
}

# Due to Blizzard bug with how they find enchants, namely how they do it by stats not valid enchant slot
# this forces it to remap to a valid one if we run into that issue
ENCHANTS["REMAP"] = {
	"chest" => {
		35426 => 38865, # Enchant Bracer - Stats -> Scroll of Enchant Chest -> Greater Stats
	},
	"pants" => {
		41605 => 41602, # zzDEPRECATED Sanctified Spellthread -> Brilliant Spellthread
	},
	"hands" => {
		35453 => 38967, # Enchant Weapon - Greater Agility -> Scroll of Enchant Gloves -> Major Agility
	}
}

ITEMS["NOTES"] = {
	#50210 => {:roles => []}
	50444 => {:roles => ["beast-hunter", "marks-hunter", "survival-hunter"], :message => "Best pre-raid Hunter ranged. Better than some Icecrown Citadel 10-man weapons, especially for Dwarves."},
	:random => "Random suffix items are not identified by Elitist Armory due to complexity, but are still shown."
}

ITEMS["ROLE_OVERRIDES"] = {
	"tank-dk" => {:type => "weapon", :roles => {"physical-dps" => true, "dps" => true, "melee-dps" => true}}
}

# And now for items, this includes item-enchants
ITEMS["OVERRIDES"] = {
	50458 => "dps", # Bizuri's Totem of Shattered Ice
	47666 => "dps", # Totem of the Electrifying Wind
	45866 => "dps", # Elemental Focusing Stone
	40707 => "tank", # Libram of Obstruction
	32368 => "tank", # Tome of the Lightbringer
	47661 => "tank/dps", # Libram of Valiance
	44255 => "caster", # Darkmoon Card: Greatness (90 INT)
	44254 => "caster-spirit", # Darkmoon Card: Greatness (90 SPI)
	44253 => "tank/dps", # Darkmoon Card: Greatness (90 AGI)
	42987 => "tank/dps", # Darkmoon Card: Greatness (90 STR)
	47668 => "tank/dps", # Idol of Mutilation
	50456 => "tank/dps", # Idol of the Crying Moon
	38365 => "tank/dps", # Idol of Perspicacious Attacks
	40714 => "tank", # Sigil of the Unfaltering Knight
	50708 => "tank", # Last Word (Heroic)
	50179 => "tank", # Last Word
	47316 => "caster-dps", # Reign of the Dead
	47477 => "caster-dps", # Reign of the Dead (Heroic)
	41376 => "situational-healer", # Revitalizing Skyflare Diamond
	50658 => "caster", # Amulet of the Silent Eulogy
	48032 => "caster", # Lightbane Focus
	50668 => "spirit/cloak", # Greatcloak of the Turned Champion (Heroic)
	50014 => "spirit/cloak", # Greatcloak of the Turned Champion
	50444 => "tank/range", # Rowan's Rifle of Silver Bullets (Best pre-raiding)
	47658 => "caster", # Brimstone Igniter
	#50210 => "caster", # Seethe
	
	# Item enchants
	38974 => "never", # Boots - Greater Vitality
	38981 => "physical-dps", # Scourgebane
	38986 => "all", # Icewalker
	38990 => "tank", # Armsman
	44957 => "tank/pvp", # Greater Inscription of the Gladiator
	38948 => "dps", # Executioner
	46098 => "tank/pvp", # Blood Draining
	46026 => "tank", # Blade Ward
	44491 => "all", # Tuskarr's Vitality
	44493 => "melee-dps", # Berserking 
	43987 => "dps", # Black Magic 
	38988 => "never", # Giant Slayer 
	37344 => "never", # Icebreaker
	38972 => "never", # Lifeward
	38993 => "pvp", # Cloak - Shadow Armor
	38893 => "never", # Cloak = Stealth
	38894 => "never", # Cloak - Threat	
	41976 => "tank/pvp", # Titanium Weapon Chain
	44497 => "tank/range", # Accuracy
	42500 => "tank", # Titanium Spike
	44936 => "tank", # Titanium Plating
	38925 => "tank/dps", # Mongoose
	41091 => "tank/dps", # Hand-Mounted Pyro Rocket
	50034 => "range-dps", # Zod's Repeating Longbow (Normal)
	50638 => "range-dps", # Zod's Repeating Longbow (Heroic)
}

# require_type => "any/all", :require => [...]
# Requires that either any one of or all the :require stats are also found to use
# exclusive => true/false
# Sets that this rule only applies if it's the only stat
# skip_on => [...]
# Indicates if any of the stats are found, to skip the rule
# max_ilvl => #
# The maximum item level this identification should be used on
ITEMS["IDENTIFY_RULES"] = [
	{:id => "never",			"gem" => ["ROOT_DURATION", "SILENCE_DURATION", "STUN_RESISTANCE", "FEAR_DURATION"]},
	{:id => "pvp",				"default" => ["RESILIENCE", "SPELL_PENETRATION"]},
	{:id => "pvp/sta",			"gem" => ["STAMINA"], :require_type => "any", :requires => ["SPELL_POWER"]},
	{:id => "all",				"gem" => ["STAT_ALL"], "enchant" => ["STAT_ALL", "RUN_SPEED"]},
	{:id => "attackpower",		"gem" => ["ATTACK_POWER"]},
        {:id => "healer",                       "gem" => ["MANA_REGEN"], :require_type => "any", :requires => ["INTELLECT", "SPELL_POWER", "SPELL_HASTE"]},
	{:id => "never",			"gem" => ["RESIST"]},
	{:id => "never",			"gem" => ["MANA_REGEN"], :exclusive => true},
	{:id => "never",			"gem" => ["MANA_REGEN"], :require_type => "any", :requires => ["AGILITY", "ATTACK_POWER", "STRENGTH"]},
	{:id => "tank",				"default" => ["DEFENSE"], "trinket" => ["WHEN_HIT"]},
	{:id => "tank",				"weapon" => ["ARMOR"], :skip_on => ["INTELLECT", "SPELL_POWER", "ARMOR_PENETRATION"]},
	{:id => "healer",			"trinket" => ["HELPFUL_SPELL"]},
	{:id => "caster-dps",		"default" => ["SPELL_HIT"], "trinket" => ["HARMFUL_SPELL", "PERIODIC_DAMAGE", "SPELL_DAMAGE"]},
	{:id => "caster-dps",		"default" => ["HIT"], :require_type => "any", :requires => ["SPELL_POWER"]},
	{:id => "physical-all",		"default" => ["AGILITY"]},
	{:id => "physical-dps",		"default" => ["ARMOR_PENETRATION"], "trinket" => ["ATTACK", "MELEE_OR_RANGE_DAMAGE", "CHANCE_MELEE_OR_RANGE", "MELEE_AND_RANGE"]},
	{:id => "melee",			"gem" => ["STRENGTH"], :require_type => "any", :requires => ["STAMINA"]},
	{:id => "caster-spirit",	"gem" => ["SPIRIT"], "enchant" => ["SPIRIT"], "trinket" => ["SPIRIT"]},
	{:id => "caster-spirit",	"default" => ["SPIRIT"], :require_type => "any", :requires => ["SPELL_POWER"]},
	{:id => "caster",			"default" => ["MANA_REGEN", "SPELL_POWER", "SPELL_HASTE", "SPELL_CRIT", "INTELLECT"], "gem" => ["MANA_REGEN"], "enchant" => ["MANA_REGEN"], :skip_on => ["AGILITY", "EXPERTISE"]},
	{:id => "caster",			"default" => ["MANA_REGEN"], :require_type => "any", :requires => ["SPELL_POWER"]},
	{:id => "tank",				"enchant" => ["ARMOR"], :exclusive => true},
	{:id => "paladin",			"enchant" => ["MANA"], :exclusive => true, :ignore_exclusive => ["ARMOR"]},
	{:id => "tank",				"default" => ["PARRY", "DODGE", "DEFENSE", "BLOCK"], "enchant" => ["STAMINA", "HEALTH"], "trinket" => ["ARMOR", "STAMINA"], "rings" => ["ARMOR"]},
	{:id => "melee",			"default" => ["EXPERTISE"]},
	{:id => "physical-dps",		"default" => ["ATTACK_POWER"]},
	{:id => "melee-dps",		"default" => ["STRENGTH"], "trinket" => ["MELEE_ATTACK"]},
	{:id => "tank/dps",			"enchant" => ["HIT"], "gem" => ["HIT"]},
	{:id => "dps",				"default" => ["HIT"], "trinket" => ["DAMAGE", "DEAL_DAMAGE"]},
	{:id => "healer/dps",		"default" => ["CRIT", "HASTE"]},
	{:id => "resist",			"default" => ["FIRE_RESIST", "NATURE_RESIST", "FROST_RESIST", "SHADOW_RESIST", "ARCANE_RESIST"]},
	{:id => "tank",				"gem" => ["STAMINA"]},
	{:id => "tank",				"range" => ["STAMINA"], :exclusive => true},
	{:id => "tank",				"default" => ["STAMINA"], :max_ilvl => 100},
]
