STATS = {} 

STATS[:ratings] = {
	"SPELLHIT" => {
		:rating => 26.232, # 1 %	
	},
	"MELEEHIT" => {
		:rating => 32.79, # 1 %
	},
	"EXPERTISE" => {
		:rating => 32.78998947, # 1%
		:value => 8.1974973675, # Rating -> Expertise
	},
	"CRIT" => {
		:rating => 45.91,
	},
	"HASTE" => {
		:rating => 32.79,
	},
}

STATS[:caps] = {
	"SPELLHIT" => {
		:rating => 446,
	},
	"MELEEHIT" => {
		:rating => 263,
	},
	"MELEEHITDW" => {
                :map => "MELEEHIT",
		:rating => 886,
	},
	"MELEEHITSPECIAL" => {
                :map => "MELEEHIT",
		:rating => 263,
	},
	"EXPERTISEDPS" => {
                :map => "EXPERTISE",
		:rating => 214,
	},
	"EXPERTISETANK" => {
                :map => "EXPERTISE",
		:rating => 460,
	},
}

#calculat cap percent 
STATS[:caps].each do |type, data|
	key = data[:map] ? data[:map] : type
	STATS[:caps][type][:percent] = (data[:rating] / STATS[:ratings][key][:rating])
	STATS[:caps][type][:value] = STATS[:ratings][key][:value] ? (data[:rating] / STATS[:ratings][key][:value]) : nil;
end

