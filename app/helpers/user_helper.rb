module UserHelper
	def account_page_active(action)
		return params["action"] == action ? "gold-text" : nil
	end
end