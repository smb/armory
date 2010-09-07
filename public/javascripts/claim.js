var ajax_data = {}
function update_status() {
	$("#progress").addClass("invisible")
	$("#verifyclaim").removeClass("invisible")
	$("#calendarurl").val("")
	$("#example").removeClass("example")
	
	if( ajax_data.error && ajax_data.error != "" ) {
		var message = ajax_data.error
		if( message == "maintenance" ) {
			message = "Armory is undergoing maintenance, try again later."
		} else if( message == "invalidAuth" ) {
			message = "Invalid token entered, are you sure it's correct?"
		} else if( message == "mismatch" ) {
			message = "Mismatched characters, are you sure you entered the URL correctly?"
		} else if( message == "eof" ) {
			message = "Malformed response, please try entering the URL again."
		} else {
			message = message + ", please try again."
		}
		
		$("#claim").addClass("red")
		$("#claim").html("Failed to verify")
		$("#example").html(message)
		$("#example").addClass("red")
	} else if( ajax_data.status == "done" ) {
		plural = ajax_data.total == 1 ? "character" : "characters"
		$("#claim").html("Found " + ajax_data.total + " " + plural)
		$("#claim").addClass("green")
		var message = "<ol>";
		for( var i=0; i<ajax_data.characters.length; i++ ) {
			var character = ajax_data.characters[i]
			if( character.status == "claimed" ) {
				message = message + "<li>Claimed, " + character.name + " - " + character.realm + "</li>"
			} else if( character.status == "selfClaimed" ) {
				message = message + "<li>You already claimed, " + character.name + " - " + character.realm + "</li>"
			} else if( character.error == "already" ) {
				message = message + "<li>Another account claimed " + character.name + " - " + character.realm + "</li>"
			}
		}
		
		$("#example").html(message + "</ol><a href=\"" + account_path + "\">Click here</a> to reload")
	}
}

function queue_loaded(json) {
	if( json ) {
		ajax_data = json
		update_status()
	}
}

function claim() {
	var url = $("#calendarurl").val()
	if( url == "" ) {
		alert("You have to enter the URL before verifying")
		return
	}

	var region = null
	if( url.match(/wow-europe.com/) ) {
		region = "eu"
	} else {
		region = url.match(/http\:\/\/([a-zA-Z]+)\.wowarmory/)[1]
		if( region == "www" || region == null ) {
			region = "us"
		}
	}
	
	var params = url.match(/ics\?(.+)/)
	if( params == null ) {
		alert("Invalid URL entered, cannot parse arguments.")
		return
	}

	params = params[1].split("&")

	var args = {}
	for( var i=0; i<params.length; i++ ) {
		arg = params[i].match(/([a-z]+)=(.+)/)
		if( arg != null ) {
			args[arg[1]] = arg[2]
		}
	}
	
	if( args.token == null || args.r == null || args.cn == null ) {
		alert("Malformed URL entered.")
		return
	}
	
	$.ajax({
		url: base_path + "api/claim/" + args.token + "/" + region + "/" + args.r + "/" + args.cn + ".json",
		dataType: "json",
		cache: false,
		success: queue_loaded,
		error: function(response) {
			$("#progress").addClass("invisible")
			$("#verifyclaim").removeClass("invisible")
			$("#calendarurl").val("")
			$("#example").removeClass("example")
			$("#claim").html("Failed to claim")
			$("#claim").addClass("red")
			
			if( response.status == 500 ) {
				$("#example").html("A script error prevented your characters from being claimed, please report this.")
			} else {
				$("#example").html("An unknown error (http " + response.status + ") was triggered when trying to claim, please report this.")
			}
		}
	})
	
	$("#progress").removeClass("invisible")
	$("#verifyclaim").addClass("invisible")
}