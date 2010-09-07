var requests = 0
var total_errors = 0
var queue_timeout = 5
var timeout

function pluralize(count, singular, plural) {
	return count > 1 && plural || singular
}

function summarize_errors(multi_errors) {
	var error_text = ""
	for( var i=0; i < multi_errors.length; i++ ) {
		var error = multi_errors[i]
		var type = error.type == "noCharacter" && pluralize(error.count, "nonexistent character", "nonexistent characters") || error.type == "inactive" && pluralize(error.count, "inactive character", "inactive characters") || error.type == "maintenance" && "armory maintenance" || error.type
		
		error_text = error_text + ", <span class='gold-text'>" + error.count + "</span> " + type
	}
	
	return error_text.substring(2)
}

function update_status(json) {
	var error = json.error
	var multi_errors = json.multi_errors
	var queue_position = parseInt(json.count)
	
	if( error && error != "" ) {
		var message = error
		if( error == "timeout" ) {
			message = "It took over 60 seconds to get armory data, you may want to try again."
		} else if( error == "inactive" ) {
			message = "It's been too long since the character has logged in. Unable to load data."
		} else if( error == "noCharacter" ) {
			message = "No character found, perhaps you entered it wrong, or the character is below level 10."
		} else if( error == "noGuild" ) {
			message = "No guild found, are you it's spelled correctly?"
		} else if( error == "maintenance" ) {
			message = "Armory appears to be undergoing maintenance. Cannot request data at this time."
		} else if( error == "503" ) {
			message = "HTTP 503, armory is unavailable. Please try again."
		} else if( error == "404" ) {
			message = "404 file not found. That's is bad, report this!"
		}
		
		$("#status").html("<span class='red'>Error!</span> " + message)
	} else if( typeof(warn_errors) != "undefined" && queue_position == 0 && multi_errors ) {
		clearTimeout(timeout)
		$("#message").html("Some characters failed to load, summary: " + summarize_errors(multi_errors))
		$("#status").html("<span class='green'>Finished!</span> <a href=\"" + reload_url + "\">Click here</a> to reload.")
	} else if( queue_position > 0 ) {
		var error = ""
		if( multi_errors ) {
			error = " (<span class='red'>" + pluralize(multi_errors.length, "Error", "Errors") + ":</span> " + summarize_errors(multi_errors) + ")"
		}
		
		$("#status").html("Position in queue: #<span class='gold-text'>" + queue_position + "</span>" + error)
	} else {
		if( no_data ) {
			$("#status").html("<span class='green'>Finished!</span> Refreshing in <span id='redirect'>2 seconds</span>, or <a class='gold-text' href=\"" + reload_url + "\">click here</a>.")
			setTimeout(function(){ $("#redirect").html("1 second") }, 1000)
			setTimeout(function(){ window.location.reload(false) }, 1800)
		} else {
			$("#status").html("<span class='green'>Finished!</span> <a class='gold-text' href=\"" + reload_url + "\">Click here</a> to reload")
		}
	}
}

var last_position = -1
function queue_loaded(json) {
	if( json ) {
		if( parseInt(json.count) != last_position ) { requests = 0 }
		last_position = parseInt(json.count)
		
		update_status(json)
		
		if( last_position == 0 || json.error ) {
			return
		} else if( last_position < 10 ) {
			queue_timeout = 2
		} else if( last_position < 50 ) {
			queue_timeout = 5
		} else if( last_position < 100 ) {
			queue_timeout = 10
		} else if( last_position < 500 ) {
			queue_timeout = 30
		} else {
			queue_timeout = 120
		}
		
		queue_timeout = queue_timeout * 1000
	}
	
	total_errors = 0
	timeout = setTimeout(poll_queue, queue_timeout)
}

function poll_queue() {
	requests = requests + 1
	
	if( requests >= 50 ) {
		error = "timeout"
		update_status()
		return
	}
	
	$.ajax({
		url: api_path,
		dataType: "json",
		cache: true,
		success: queue_loaded,
		error: function(xml) {
			if( total_errors <= 2 ) {
				total_errors = total_errors + 1
				setTimeout(poll_queue, queue_timeout * 2)
			}
		}
	})
}

$(document).ready(function() {
	poll_queue()
})