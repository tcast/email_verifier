module EmailVerifier
	class EmailRequiredException < StandardError; end
	class EmailFormatIncorrectException < StandardError; end
  class NoMailServerException < StandardError; end
  class OutOfMailServersException < StandardError; end
  class NotConnectedException < StandardError; end
  class FailureException < StandardError; end
end