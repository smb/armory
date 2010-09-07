ACHIEVEMENTS = {}
ACHIEVEMENTS[:achiev_cat] = 168
ACHIEVEMENTS[:stat_cat] = 14807

DUNGEONS = {}
DUNGEONS[:suggested] = [
	{:name => "T7 Dungeons",				:ilvl => 200,	:players => 5,		:type => "heroic",	:key => "5h"},
	{:name => "Sartharion",					:ilvl => 200,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Naxxramas",					:ilvl => 200,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Archavon, Vault",			:ilvl => 200,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Naxxramas",					:ilvl => 213,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Malygos",					:ilvl => 213,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Archavon, Vault",			:ilvl => 213,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Malygos",					:ilvl => 226,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Sartharion",					:ilvl => 226,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "T9 Dungeons",				:ilvl => 219,	:players => 5,		:type => "heroic",	:key => "5h"},
	{:name => "Ulduar",						:ilvl => 219,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Emalon, Vault",				:ilvl => 219,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Ulduar",						:ilvl => 226,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Emalon, Vault",				:ilvl => 226,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Ulduar",						:ilvl => 226,	:players => 10,		:type => "heroic",	:key => "10h"},
	{:name => "Ulduar",						:ilvl => 239,	:players => 25,		:type => "heroic",	:key => "25h"},
	{:name => "T10 Dungeons",				:ilvl => 232,	:players => 5,		:type => "heroic",	:key => "5h"},
	{:name => "Koralon, Vault",				:ilvl => 232,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Crusader",					:ilvl => 232,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Onyxia's Lair",				:ilvl => 232,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Onyxia's Lair",				:ilvl => 245,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Koralon, Vault",				:ilvl => 245,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Crusader",					:ilvl => 245,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Trial of the Grand Crusader",:ilvl => 245,	:players => 10,		:type => "heroic",	:key => "10h"},
	{:name => "Icecrown Citadel",			:ilvl => 251,	:players => 10,		:type => "normal",	:key => "10m"},
	{:name => "Grand Crusader",				:ilvl => 258,	:players => 25,		:type => "heroic",	:key => "25h"},
	{:name => "Icecrown Citadel",			:ilvl => 264,	:players => 25,		:type => "normal",	:key => "25m"},
	{:name => "Icecrown Citadel",			:ilvl => 264,	:players => 10,		:type => "heroic",	:key => "10h"},
	{:name => "Icecrown Citadel",			:ilvl => 277,	:players => 25,		:type => "heroic",	:key => "25h"},
]

base_mod = 0.89
DUNGEONS[:min_level] = 1000
DUNGEONS[:max_level] = 0

DUNGEONS[:suggested].each do |data|
	modifier = base_mod
	if data[:players] >= 10
		modifier = modifier + 0.01
		
		if data[:type] == "heroic" or data[:type] == "hard"
			modifier = modifier + 0.01
		end
	end
	
	data[:ilvl] = data[:ilvl] * modifier
	
	if data[:ilvl] < DUNGEONS[:min_level]
		DUNGEONS[:min_level] = data[:ilvl]
	end
	
	if data[:ilvl] > DUNGEONS[:max_level]
		DUNGEONS[:max_level] = data[:ilvl]
	end
end

DUNGEONS[:level_diff] = DUNGEONS[:max_level] - DUNGEONS[:max_level]

DUNGEONS[:exp_select] = [
	["25-man raids", [["Vault of Archavon", "voa25"], ["Naxxramas", "naxx25"], ["Malygos", "maly25"], ["Sartharion", "sarth25"], ["Ulduar", "uld25"], ["Trial of the Crusader", "toc25"], ["Icecrown Citadel", "icc25"], ["The Ruby Sanctum", "rs25"]].reverse],
	["10-man raids", [["Vault of Archavon", "voa10"], ["Naxxramas", "naxx10"], ["Malygos", "maly10"], ["Sartharion", "sarth10"], ["Ulduar", "uld10"], ["Trial of the Crusader", "toc10"], ["Icecrown Citadel", "icc10"], ["The Ruby Sanctum", "rs10"]].reverse],
	["5-man dungeons", [["Tier 7 & 9 dungeons", "dungeont9"], ["Tier 10 dungeons", "dungeont10"]].reverse],
]

DUNGEONS[:child_maps] = {
	"naxx10" => ["10m-naxx"],
	"naxx25" => ["25m-naxx"],
	"maly10" => ["10m-malygos"],
	"maly25" => ["25m-malygos"],
	"sarth10" => ["10m-sarth", "10m-h-sarth"],
	"sarth25" => ["25m-sarth", "25m-h-sarth"],
	"voa10" => ["10m-voa"],
	"voa25" => ["25m-voa"],
	"uld10" => ["10m-ulduar", "10m-h-ulduar"],
	"uld25" => ["25m-ulduar", "25m-h-ulduar"],
	"toc10" => ["10m-toc", "10m-h-togc"],
	"toc25" => ["25m-toc", "25m-h-togc"],
	"icc10" => ["10m-icc", "10m-h-icc"],
	"icc25" => ["25m-icc", "25m-h-icc"],
	"rs10" => ["10m-rs", "10m-h-rs"],
	"rs25" => ["25m-rs", "25m-h-rs"],
	"dungeont9" => ["t7-t9-dungeons"],
	"dungeont10" => ["t10-dungeons"],
}

EXPERIENCE = {
	:dungeons => [
		{:name => "Tier 7 & 9", :icon => "icons/spell_frost_frozencore.png",
			:children => [
				{:players => 5, :data_id => "t7-t9-dungeons", :heroic => true,
					:experienced => 30,
					:achievements => {
						1504 => 5, # Ingvar the Plunderer kills (Heroic Utgarde Keep)
						1505 => 5, # Keristrasza kills (Heroic Nexus)
						1506 => 5, # Anub'arak kills (Heroic Azjol-Nerub)
						1507 => 5, # Herald Volazj kills (Heroic Ahn'kahet)
						1508 => 5, # The Prophet Tharon'ja kills (Heroic Drak'Tharon Keep)
						1509 => 5, # Cyanigosa kills (Heroic Violet Hold)
						1510 => 5, # Gal'darah kills (Heroic Gundrak)
						1511 => 5, # Sjonnir the Ironshaper kills (Heroic Halls of Stone)
						1512 => 5, # Loken kills (Heroic Halls of Lightning)
						1513 => 5, # Ley-Guardian Eregos kills (Heroic Oculus)
						1514 => 5, # King Ymiron kills (Heroic Utgarde Pinnacle)
						1515 => 5, # Mal'Ganis defeated (Heroic CoT: Stratholme)
						4027 => 5, # The Black Knight kills (Heroic Trial of the Champion)
						2136 => 50, # Glory of the Hero
					}
				},
			],
		},
		{:name => "Tier 10", :icon => "icons/spell_fire_felflamebreath.png",
			:children => [
				{:players => 5, :data_id => "t10-dungeons", :heroic => true,
					:experienced => 70,
					:achievements => {
						4714 => 1, # Bronjahm kills (Heroic Forge of Souls)
						4716 => 2, # Devourer of Souls kills (Heroic Forge of Souls)
						4519 => 20, # Heroic: The Forge of Souls
						4719 => 1, # Ick and Krick kills (Heroic Pit of Saron)
						4728 => 1, # Forgemaster Garfrost kills (Heroic Pit of Saron)
						4721 => 2, # Scourgelord Tyrannus kills (Heroic Pit of Saron)
						4520 => 20, # Heroic: The Pit of Saron
						4723 => 1, # Falric kills (Heroic Halls of Reflection)
						4725 => 2, # Marwyn kills (Heroic Halls of Reflection)
						4727 => 5, # Lich King escapes (Heroic Halls of Reflection)
						4521 => 20, # Heroic: The Halls of Reflection
					},
				},
			],
		},
	],
	:raids => [
		{:name => "Naxxramas", :icon => "icons/achievement_dungeon_naxxramas_10man.png",
			:children => [
				{:players => 10, :data_id => "10m-naxx",
					:experienced => 130, # 3 full clears / 2 full clears + undying
					:achievements => {
						1361 => 2, # Anub'Rekhan kills (Naxxramas 10 player)
						1362 => 2, # Grand Widow Faerlina kills (Naxxramas 10 player)
						1363 => 6, # Maexxna kills (Naxxramas 10 player)
						1364 => 1, # Patchwerk kills (Naxxramas 10 player)
						1371 => 1, # Grobbulus kills (Naxxramas 10 player)
						1372 => 2, # Gluth kills (Naxxramas 10 player)
						1373 => 6, # Thaddius kills (Naxxramas 10 player)
						1365 => 2, # Noth the Plaguebringer kills (Naxxramas 10 player)
						1369 => 2, # Heigan the Unclean kills (Naxxramas 10 player)
						1370 => 6, # Loatheb kills (Naxxramas 10 player)
						1374 => 2, # Instructor Razuvious kills (Naxxramas 10 player)
						1366 => 2, # Gothik the Harvester kills (Naxxramas 10 player)
						1375 => 6, # Four Horsemen kills (Naxxramas 10 player)
						1376 => 10, # Sapphiron kills (Naxxramas 10 player)
						1377 => 15, # Kel'Thuzad kills (Naxxramas 10 player)
						576 => 65, # The Fall of Naxxramas (10 player)
						2187 => 65, # The Undying
					},
				},
				{:players => 25, :data_id => "25m-naxx",
					:experienced => 130, # 3 full clears/2 full clears + immortal
					:achievements => {
						1368 => 2, # Anub'Rekhan kills (Naxxramas 25 player)
						1380 => 2, # Grand Widow Faerlina kills (Naxxramas 25 player)
						1386 => 6, # Maexxna kills (Naxxramas 25 player)
						1367 => 1, # Patchwerk kills (Naxxramas 25 player)
						1381 => 1, # Grobbulus kills (Naxxramas 25 player)
						1378 => 2, # Gluth kills (Naxxramas 25 player)
						1388 => 6, # Thaddius kills (Naxxramas 25 player)
						1387 => 2, # Noth the Plaguebringer kills (Naxxramas 25 player)
						1382 => 2, # Heigan the Unclean kills (Naxxramas 25 player)
						1385 => 6, # Loatheb kills (Naxxramas 25 player)
						1384 => 2, # Instructor Razuvious kills (Naxxramas 25 player)
						1379 => 2, # Gothik the Harvester kills (Naxxramas 25 player)
						1383 => 6, # Four Horsemen kills (Naxxramas 25 player)
						1389 => 10, # Sapphiron kills (Naxxramas 25 player)
						1390 => 15, # Kel'Thuzad kills (Naxxramas 25 player)
						577 => 70, # The Fall of Naxxramas (25 player)
						2186 => 70, # The Immortal
					},
				},
			],
		},
		{:name => "Malygos", :icon => "icons/achievement_dungeon_nexusraid_10man.png",
			:children => [
				{:players => 10, :data_id => "10m-malygos",
					:experienced => 10, # 3 kills or a sub-6 minute kill
					:achievements => {
						1391 => 10, # Malygos kills (10 player)
						1874 => 30, # You Don't Have An Eternity (10 player)
					},
				},
				{:players => 25, :data_id => "25m-malygos",
					:experienced => 10,
					:achievements => {
						1394 => 10, # Malygos kills (25 player)
						1875 => 30, # You Don't Have An Eternity (25 player)
					},
				},
			],
		},
		{:name => "Sartharion", :icon => "icons/achievement_dungeon_coablackdragonflight_10man.png", 
			:children => [
				{:players => 10, :data_id => "10m-sarth",
					:experienced => 10, # 3 kills or a 3-drake kill
					:achievements => {
						1392 => 10, # Sartharion kills (Chamber of the Aspects 10 player)
					},
				},
				{:players => 10, :heroic => true, :cascade => "10m-sarth", :data_id => "10m-h-sarth",
					:experienced => 30, # 3 kills or a 3-drake kill
					:achievements => {
						2049 => 5, # Twilight Assist (10 player) - 1 drake
						2050 => 10, # Twilight Duo (10 player) - 2 drakes
						2051 => 30, # The Twilight Zone (10 player) - 3 drakes
					},
				},
				{:players => 25, :data_id => "25m-sarth",
					:experienced => 10, # 3 kills or 3-drake
					:achievements => {
						1393 => 10, # Sartharion kills (Chamber of the Aspects 25 player)
					},
				},
				{:players => 25, :heroic => true, :cascade => "25m-sarth", :data_id => "25m-h-sarth",
					:experienced => 30, # 3 kills or 3-drake
					:achievements => {
						2052 => 5, # Twilight Assist (10 player) - 1 drake
						2053 => 10, # Twilight Duo (10 player) - 2 drakes
						2054 => 30, # The Twilight Zone (25 player) - 3 drakes
					},
				},
			],
		},
		{:name => "Vault of Archavon", :icon => "icons/spell_nature_elementalprecision_2.png",
			:children => [
				{:players => 10, :data_id => "10m-voa",
					:experienced => 30, # Basically, 3 Toravon kills or some combination of a Toravon kill + Emalon + Koralon
					:cap => {
						1753 => 5,
						2870 => 5,
						4074 => 5,
					},
					:achievements => {
						4016 => 30, # Earth, Wind & Fire (10 player)
						1753 => 1, # Archavon the Stone Watcher kills (Wintergrasp 10 player)
						2870 => 1, # Emalon the Storm Watcher kills (Wintergrasp 10 player)
						4074 => 1, # Koralon the Flame Watcher kills (Wintergrasp 10 player)
						4657 => 30, # Toravon the Ice Watcher kills (Wintergrasp 10 player)
					},
				},
				{:players => 25, :data_id => "25m-voa",
					:experienced => 30, # Basically, 3 Toravon kills or some combination of a Toravon kill + Emalon + Koralon
					:cap => {
						1754 => 5,
						3236 => 5,
						4075 => 5,
					},
					:achievements => {
						4017 => 30, # Earth, Wind & Fire (25 player)
						1754 => 1, # Archavon the Stone Watcher kills (Wintergrasp 25 player)
						3236 => 1, # Emalon the Storm Watcher kills (Wintergrasp 25 player)
						4075 => 1, # Koralon the Flame Watcher kills (Wintergrasp 25 player)
						4658 => 30, # Toravon the Ice Watcher kills (Wintergrasp 25 player)
					},
				},
			],
		},
		{:name => "Onyxia's Lair", :icon => "icons/achievement_boss_onyxia.png",
			:children => [
				{:players => 10, :data_id => "10m-onyxia",
					:experienced => 10, # Only an achievement for Onyxia, no stats
					:achievements => {
						4396 => 10, # Onyxia's Lair (10 player)
					},
				},
				{:players => 25, :data_id => "25m-onyxia",
					:experienced => 10, # Only an achievement for Onyxia, no stats
					:achievements => {
						4397 => 10, # Onyxia's Lair (25 player)
					},
				},
			],
		},
		{:name => "Ulduar", :icon => "icons/achievement_boss_algalon_01.png", 
			:children => [
				{:players => 10, :data_id => "10m-ulduar",
					:experienced => 240, # 3 full clears, 2 with Champion of Ulduar, Algalon is a bonus
					:achievements => {
						2856 => 1, # Flame Leviathan kills (Ulduar 10 player)
						2857 => 1, # Razorscale kills (Ulduar 10 player)
						2858 => 1, # Ignis the Furnace Master kills (Ulduar 10 player)
						2859 => 2, # XT-002 Deconstructor kills (Ulduar 10 player)
						2860 => 3, # Assembly of Iron kills (Ulduar 10 player)
						2868 => 1, # Auriaya kills (Ulduar 10 player)
						2861 => 1, # Kologarn kills (Ulduar 10 player)
						2862 => 5, # Hodir victories (Ulduar 10 player)
						2863 => 5, # Thorim victories (Ulduar 10 player)
						2864 => 5, # Freya victories (Ulduar 10 player)
						2865 => 5, # Mimiron victories (Ulduar 10 player)
						2866 => 10, # General Vezax kills (Ulduar 10 player)
						2869 => 15, # Yogg-Saron kills (Ulduar 10 player)
						2867 => 15, # Algalon the Observer kills (Ulduar 10 player)
						2894 => 60, # The Secrets of Ulduar (10 player)
						2903 => 60, # Champion of Ulduar
					},
				},
				{:players => 25, :data_id => "25m-ulduar",
					:experienced => 240, # 3 full clears, 2 with Conqueror of Ulduar, Algalon is a bonus
					:achievements => {
						2872 => 1, # Flame Leviathan kills (Ulduar 25 player)
						2873 => 1, # Razorscale kills (Ulduar 25 player)
						2874 => 1, # Ignis the Furnace Master kills (Ulduar 25 player)
						2884 => 2, # XT-002 Deconstructor kills (Ulduar 25 player)
						2885 => 3, # Assembly of Iron kills (Ulduar 25 player)
						2882 => 1, # Auriaya kills (Ulduar 25 player)
						2875 => 1, # Kologarn kills (Ulduar 25 player)
						2879 => 5, # Mimiron victories (Ulduar 25 player)
						3256 => 5, # Hodir victories (Ulduar 25 player)
						3257 => 5, # Thorim victories (Ulduar 25 player)
						3258 => 5, # Freya victories (Ulduar 25 player)
						2880 => 10, # General Vezax kills (Ulduar 25 player)
						2883 => 15, # Yogg-Saron kills (Ulduar 25 player)
						2881 => 15, # Algalon the Observer kills (Ulduar 25 player)
						2895 => 60, # The Secrets of Ulduar (25 player)
						2904 => 60, # Conqueror of Ulduar
					}
				},
				{:players => 10, :heroic => true, :data_id => "10m-h-ulduar", :cascade => "10m-ulduar",
					:experienced => 110, # Requires one full hardmode clear, or a combination of Feeds on tears/0 lights
					:achievements => {
						2941 => 15, # I Choose You, Steelbreaker (10 player)
						3056 => 5, # Orbit-uary (10 player)
						3058 => 10, # Heartbreaker (10 player)
						3182 => 10, # I Could Say That This Cache Was Rare (10 player)
						3158 => 25, # One Light in the Darkness (10 player)
						3159 => 50, # Alone in the Darkness (10 player)
						3179 => 15, # Knock, Knock, Knock on Wood (10 player)
						3180 => 15, # Firefighter (10 player)
						3181 => 15, # I Love the Smell of Saronite in the Morning (10 player)
						3004 => 50, # He Feeds On Your Tears (10 player)
					},
				},
				{:players => 25, :heroic => true, :data_id => "25m-h-ulduar", :cascade => "25m-ulduar",
					:experienced => 110, # Requires one full hardmode clear, or a combination of Feeds on tears/0 lights
					:achievements => {
						2944 => 15, # I Choose You, Steelbreaker (25 player)
						3057 => 5, # Orbit-uary (25 player)
						3059 => 10, # Heartbreaker (25 player)
						3184 => 10, # I Could Say That This Cache Was Rare (25 player)
						3163 => 25, # One Light in the Darkness (25 player)
						3164 => 50, # Alone in the Darkness (25 player)
						3187 => 15, # Knock, Knock, Knock on Wood (25 player)
						3188 => 15, # I Love the Smell of Saronite in the Morning (25 player)
						3189 => 15, # Firefighter (25 player)
						3005 => 50, # He Feeds On Your Tears (25 player)
					},
				},
			]
		},
		{:name => "Trial of the Crusader", :icon => "icons/achievement_reputation_argentchampion.png",
			:children => [
				# Right now, the ToC10 and ToCG10 completion stats are bugged, going to include them so data is recorded, but it's worth 0 right now
				{:players => 10, :data_id => "10m-toc",
					:experienced => 40, # Slightly wonky, first 4 bosses killed 3 times, with one being a full clear
					:achievements => {
						4028 => 1, # Victories over the Beasts of Northrend (Trial of the Crusader 10 player)
						4032 => 2, # Lord Jaraxxus kills (Trial of the Crusader 10 player)
						4036 => 3, # Victories over the Faction Champions (Trial of the Crusader 10 player)
						4040 => 4, # Val'kyr Twins kills (Trial of the Crusader 10 player)
						4044 => 0, # Times completed the Trial of the Crusader (10 player)
						3917 => 10, # Call of the Crusade (10 player)
					},
				},
				{:players => 25, :data_id => "25m-toc",
					:experienced => 40, # 3 full clears
					:achievements => {
						4031 => 0, # Victories over the Beasts of Northrend (Trial of the Crusader 25 player)
						4034 => 1, # Lord Jaraxxus kills (Trial of the Crusader 25 player)
						4038 => 1, # Victories over the Faction Champions (Trial of the Crusader 25 player)
						4042 => 2, # Val'kyr Twins kills (Trial of the Crusader 25 player)
						4046 => 6, # Times completed the Trial of the Crusader (25 player)
						3916 => 10, # Call of the Crusade (25 player)
					},
				},
				{:players => 10, :heroic => true, :data_id => "10m-h-togc", :cascade => "10m-toc",
					:experienced => 50, # first 4 bosses killed 4 times with one full clear, 3 with >=45 attempts, 1 with 50 attempts
					:achievements => {
						4030 => 0, # Victories over the Beasts of Northrend (Trial of the Grand Crusader 10 player)
						4033 => 0, # Lord Jaraxxus kills (Trial of the Grand Crusader 10 player)
						4037 => 4, # Victories over the Faction Champions (Trial of the Grand Crusader 10 player)
						4041 => 6, # Val'kyr Twins kills (Trial of the Grand Crusader 10 player)
						4045 => 0, # Times completed the Trial of the Grand Crusader (10 player)
						3918 => 10, # Call of the Grand Crusade (10 player)
						3809 => 10, # A Tribute to Mad Skill (10 player)
						3810 => 30, # A Tribute to Insanity (10 player)
						4080 => 30, # A Tribute to Dedicated Insanity
					},
				},
				{:players => 25, :heroic => true, :data_id => "25m-h-togc", :cascade => "25m-toc",
					:experienced => 50, # 4 full clears, or 3 full clears + mad skill, 1 full clear + insanity
					:achievements => {
						4029 => 0, # Victories over the Beasts of Northrend (Trial of the Grand Crusader 25 player)
						4035 => 0, # Lord Jaraxxus kills (Trial of the Grand Crusader 25 player)
						4039 => 0, # Victories over the Faction Champions (Trial of the Grand Crusader 25 player)
						4043 => 4, # Val'kyr Twins kills (Trial of the Grand Crusader 25 player)
						4047 => 8, # Times completed the Trial of the Grand Crusader (25 player)
						3812 => 10, # Call of the Grand Crusade (25 player)
						3818 => 10, # A Tribute to Mad Skill (25 player)
						3819 => 30, # A Tribute to Insanity (25 player)
					},
				},
			]
		},
		{:name => "Icecrown Citadel", :icon => "icons/achievement_boss_lichking.png",
			:children => [
				{:players => 10, :data_id => "10m-icc",
					:experienced => 195, # 3 full clears
					:cap => {
						4639 => 10,
						4643 => 10,
						4644 => 10,
						4645 => 10,
					},
					:achievements => {
						4639 => 1, # Lord Marrowgar kills (Icecrown 10 player)
						4643 => 1, # Lady Deathwhisper kills (Icecrown 10 player)
						4644 => 1, # Gunship Battle victories (Icecrown 10 player)
						4645 => 1, # Deathbringer kills (Icecrown 10 player)
						4646 => 1, # Festergut kills (Icecrown 10 player)
						4647 => 2, # Rotface kills (Icecrown 10 player)
						4650 => 5, # Professor Putricide kills (Icecrown 10 player)
						4648 => 2, # Blood Prince Council kills (Icecrown 10 player)
						4651 => 5, # Blood Queen Lana'thel kills (Icecrown 10 player)
						4649 => 2, # Valithria Dreamwalker rescues (Icecrown 10 player)
						4652 => 5, # Sindragosa kills (Icecrown 10 player)
						4653 => 30, # Victories over the Lich King (Icecrown 10 player)
						#4527 => 5, # The Frostwing Halls (10 player)
						#4528 => 5, # The Plagueworks (10 player)
						#4529 => 5, # The Crimson Hall (10 player)
						#4531 => 5, # Storming the Citadel (10 player)
						4532 => 45, # Fall of the Lich King (10 player)
					},
				},
				{:players => 25, :data_id => "25m-icc",
					:experienced => 195, # 3 full clears
					:cap => {
						4641 => 10,
						4655 => 10,
						4660 => 10,
						4663 => 10,
					},
					:achievements => {
						4641 => 1, # Lord Marrowgar kills (Icecrown 25 player)
						4655 => 1, # Lady Deathwhisper kills (Icecrown 25 player)
						4660 => 1, # Gunship Battle victories (Icecrown 25 player)
						4663 => 1, # Deathbringer kills (Icecrown 25 player)
						4666 => 1, # Festergut kills (Icecrown 25 player)
						4669 => 2, # Rotface kills (Icecrown 25 player)
						4678 => 5, # Professor Putricide kills (Icecrown 25 player)
						4672 => 2, # Blood Prince Council kills (Icecrown 25 player)
						4681 => 5, # Blood Queen Lana'thel kills (Icecrown 25 player)
						4675 => 2, # Valithria Dreamwalker rescues (Icecrown 25 player)
						4683 => 5, # Sindragosa kills (Icecrown 25 player)
						4687 => 30, # Victories over the Lich King (Icecrown 25 player)
						#4604 => 0, # Storming the Citadel (25 player)
						#4605 => 0, # The Plagueworks (25 player)
						#4606 => 0, # The Crimson Hall (25 player)
						#4607 => 0, # The Frostwing Halls (25 player)
						4608 => 45, # Fall of the Lich King (25 player)
					},
				},
				{:players => 10, :heroic => true, :data_id => "10m-h-icc", :cascade => "10m-icc",
					:experienced => 125, # 1 full clear
					:cap => {
						4640 => 5,
						4659 => 5,
						4668 => 5,
						4671 => 5,
					},
					:achievements => {
						4640 => 1, # Lord Marrowgar kills (Heroic Icecrown 10 player)
						4654 => 5, # Lady Deathwhisper kills (Heroic Icecrown 10 player)
						4659 => 1, # Gunship Battle victories (Heroic Icecrown 10 player)
						4662 => 2, # Deathbringer kills (Heroic Icecrown 10 player)
						4665 => 2, # Festergut kills (Heroic Icecrown 10 player)
						4668 => 1, # Rotface kills (Heroic Icecrown 10 player)
						4677 => 5, # Professor Putricide kills (Heroic Icecrown 10 player)
						4671 => 1, # Blood Prince Council kills (Heroic Icecrown 10 player)
						4680 => 5, # Blood Queen Lana'thel kills (Heroic Icecrown 10 player)
						4674 => 2, # Valithria Dreamwalker rescues (Heroic Icecrown 10 player)
						4684 => 7, # Sindragosa kills (Heroic Icecrown 10 player)
						4686 => 15, # Victories over the Lich King (Heroic Icecrown 10 player)
						#4628 => 0, # Heroic: Storming the Citadel (10 player)
						#4629 => 0, # Heroic: The Plagueworks (10 player)
						#4630 => 0, # Heroic: The Crimson Hall (10 player)
						#4631 => 0, # Heroic: The Frostwing Halls (10 player)
						4636 => 45, # Heroic: Fall of the Lich King (10 player)
					},
				},
				{:players => 25, :heroic => true, :data_id => "25m-h-icc", :cascade => "25m-icc",
					:experienced => 125, # 1 full clear
					:cap => {
						4642 => 5,
						4661 => 5,
						4673 => 5,
						4670 => 5,
					},
					:achievements => {
						4642 => 1, # Lord Marrowgar kills (Heroic Icecrown 25 player)
						4656 => 5, # Lady Deathwhisper kills (Heroic Icecrown 25 player)
						4661 => 1, # Gunship Battle victories (Heroic Icecrown 25 player)
						4664 => 2, # Deathbringer kills (Heroic Icecrown 25 player)
						4667 => 2, # Festergut kills (Heroic Icecrown 25 player)
						4670 => 1, # Rotface kills (Heroic Icecrown 25 player)
						4679 => 5, # Professor Putricide kills (Heroic Icecrown 25 player)
						4673 => 1, # Blood Prince Council kills (Heroic Icecrown 25 player)
						4682 => 2, # Blood Queen Lana'thel kills (Heroic Icecrown 25 player)
						4676 => 2, # Valithria Dreamwalker rescues (Heroic Icecrown 25 player)
						4685 => 7, # Sindragosa kills (Heroic Icecrown 25 player)
						4688 => 15, # Victories over the Lich King (Heroic Icecrown 25 player)
						#4632 => 0, # Heroic: Storming the Citadel (25 player)
						#4633 => 0, # Heroic: The Plagueworks (25 player)
						#4634 => 0, # Heroic: The Crimson Hall (25 player)
						#4635 => 0, # Heroic: The Frostwing Halls (25 player)
						4637 => 45, # Heroic: Fall of the Lich King (25 player)
					},
				},
			],
		},
		{:name => "The Ruby Sanctum", :icon => "icons/spell_shadow_twilight.png", 
			:children => [
				{:players => 10, :data_id => "10m-rs", 
					:experienced => 45, # 3 full clears
					:achievements => {
						4821 => 5, # SHalion kills (Ruby Sanctum 10 player)
						4817 => 30, #  The Twilight Destroyer (10 player)
					}
				},
				{:players => 25, :data_id => "25m-rs",
					:experienced => 45, # 3 full clears
					:achievements => {
						4820 => 5, # Halion kills (Ruby Sanctum 25 player)
						4815 => 30, # The Twilight Destroyer (25 player)
					}
				},
				{:players => 10, :heroic => true, :data_id => "10m-h-rs", :cascade => "10m-rs",
					:experienced => 45, # 3 full clears
					:achievements => {
						4822 => 5, # Halion kills (Heroic Ruby Sanctum 10 player)
						4818 => 30, # Heroic: The Twilight Destroyer (10 player)
					}
				},
				{:players => 25, :heroic => true, :data_id => "25m-h-rs", :cascade => "25m-rs",
					:experienced => 45, # 3 full clears
					:achievements => {
						4823 => 5, # Halion kills (Heroic Ruby Sanctum 25 player)
						4816 => 30, # Heroic: The Twilight Destroyer (25 player)
					},
				}
			]
		},
	],
}

DUNGEONS[:data] = {}

# Turn it into a simple list so we can easily filter which achievements are and are not relevant
ACHIEVEMENTS[:tracked] = {}
ACHIEVEMENTS[:relationships] = {}
ACHIEVEMENTS[:caps] = {}
EXPERIENCE.each do |key, types|
	types.each do |instance|
		instance[:children].each do |child|
			child[:achievements].each do |achievement_id, amount|
				ACHIEVEMENTS[:tracked][achievement_id] = amount
				ACHIEVEMENTS[:relationships][achievement_id] = child[:data_id]
			end
			
			DUNGEONS[:data][child[:data_id]] = child
			
			if !child[:cap].nil?
				child[:cap].each do |achievement_id, amount|
					ACHIEVEMENTS[:caps][achievement_id] = amount
				end
			end
		end
	end
end 