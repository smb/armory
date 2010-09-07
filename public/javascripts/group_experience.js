var loaded_exp = {}

function data_loaded(exp) {
	if( !exp ) { return }
	
	normal_dungeon = exp.normal_key
	heroic_dungeon = exp.heroic_key
	for( var i=0; i < table_data.length; i++ ) {
		var character = table_data[i]
		if( exp.data[character.id] ) {
			character.expn = exp.data[character.id][0]
			character.exph = exp.data[character.id][1]
		} else {
			character.expn = null
			character.exph = null
		}
	}
	
	if( previous_column == "expn" || previous_column == "exph" ) {
		setup_table()
	} else {
		update_table()
	}
}

function load_experience(dungeon_key) {
	if( loaded_exp[dungeon_key] ) {
		data_loaded(loaded_exp[dungeon_key])
		return
	}
	
	$("#progress").removeClass("invisible")
	$.ajax({
		url: "/group/exp/" + session_id + "/" + dungeon_key,
		dataType: "json",
		cache: false,
		success: function(exp) {
			$("#progress").addClass("invisible")

			if( exp.error ) {
				if( exp.error == "noSession" ) {
					alert("Cannot found session " + session_id + " to load experience.")
				}
				return
			}
			
			loaded_exp[dungeon_key] = exp
			data_loaded(exp)
		},
	})
}

function setup_experience() {
	var jsdata = location.href.match("#(.+)")
	var key = jsdata && jsdata[1].match(":d(.+)")
	if( key ) {
		extra_meta = ":d" + key[1]
		$("#dungeonsel").val(key)
		load_experience(key[1])
	}

	$("#dungeonsel").change(function() {
		var key = $(this).val()
		if( key == "" ) { return }

		if( typeof(extra_meta) != "undefined" ) {
			location.href = location.href.replace(extra_meta, "")
		}

		if( location.href.match("#") ) {
			location.href = location.href + ":d" + key
		} else {
			location.href = location.href + "#:d" + key
		}

		extra_meta = ":d" + key
		load_experience(key)
	})
}