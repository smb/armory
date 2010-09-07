module Armory
	# Armory is under maintenance
	class ArmoryMaintenanceError < RuntimeError; end
	
	# Response was malformed in way from a remote node
	class MalformedResponseError < RuntimeError; end

	# Raised on error when claiming a character
	class ClaimError < RuntimeError; end

	# Raised when a remote node triggers an error
	class RequestNodeError < RuntimeError; end
	
	# Raised when the armory is temporarily unavailable
	class TemporarilyUnavailableError < RuntimeError; end
		
	# Raised when an armory job raises a custom exception that should be specifically loged
	class ArmoryParseError < RuntimeError; end

	# Raised whenever we need a queue but none is provided.
	class NoQueueError < RuntimeError; end

	# Raised when trying to create a job without a class
	class NoClassError < RuntimeError; end
end
