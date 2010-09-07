var loaded_exp = {}
var dungeon_names = {}
var current_tab;

function data_loaded(character_hash, exp) {
	if( !exp ) { return }
	
	for( var child_id in exp ) {
		percent = exp[child_id]
		color = "red"
		if( percent >= 0.90 ) {
			color = "green"
		} else if( percent >= 0.60 ) {
			color = "yellow"
		} else if( percent >= 0.40 ) {
			color = "orange"
		}
		
		percent = percent > 1 ? 1 : percent
		$("#" + child_id).removeClass("red").removeClass("green").removeClass("yellow").removeClass("orange").addClass(color)
		$("#" + child_id).html(Math.floor(percent * 100) + "%")
		$("#" + child_id).mouseenter(function() {
			ttlib.requestTooltip("/tooltip/achievement/" + $(this).attr("id") + "/" + character_hash)
		})
	}
}

function loading_data() {
	$("span.expdata").removeClass("red").removeClass("green").removeClass("yellow").removeClass("orange")
	$("span.expdata").html("---")
	$("span.dungeonname").html("Loading")
}

function load_char(character_hash) {
	current_tab = character_hash
	if( loaded_exp[character_hash] ) {
		data_loaded(character_hash, loaded_exp[character_hash])
		return
	}
	
	loading_data()
	results = character_hash.split(":", 3)
	
	$.ajax({
		url: "/api/exp/" + results[0] + "/" + results[1] + "/" + results[2],
		dataType: "json",
		cache: false,
		success: function(exp) {
			for( var name in dungeon_names ) {
				$(dungeon_names[name]).html(name)
			}
			
			loaded_exp[character_hash] = exp
			data_loaded(character_hash, exp)
		},
	})
}

$(document).ready(function() {
	$("div.mainexp > span").mouseenter(function(event) {
		$(this).addClass("highlight")
	})
	$("div.mainexp > span").mouseleave(function(event) {
		$(this).removeClass("highlight")
	})
	$("div.mainexp > span").click(function(event) {
		if( $(this).is("selected") ) { return }
		$("div.mainexp > span").removeClass("selected")
		$(this).addClass("selected")
		
		load_char($(this).attr("id"))
	})
	
	names = $("span.dungeonname")
	for( var i=0; i < names.length; i++ ) {
		dungeon_names[$(names[i]).html()] = names[i]
	}
})
