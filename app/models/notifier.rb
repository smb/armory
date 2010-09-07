class Notifier < ActionMailer::Base
	def forgot_password(user, request_ip)
		subject "Password retrivial for #{user.login}"
		from "Elitist Armory <noreply@elitistarmory.com>"
		sent_on Time.now
		recipients user.email
		body :reset_url => edit_password_reset_url(user.perishable_token), :user => user, :request_ip => request_ip
	end
	
	def alert(title, message)
		subject title
		from "services@elitistarmory.com"
		recipients "alerts@elitistarmory.com"
		body :message => message
	end
end
