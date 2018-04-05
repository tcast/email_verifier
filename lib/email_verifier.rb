require "email_verifier/version"

module EmailVerifier
	require 'email_verifier/checker'
	require 'email_verifier/exceptions'
	require 'email_verifier/config'

	# returns true/false stating if an email is valid or not.
	def self.check!(email, proxy={})
    verifier = EmailVerifier::Checker.new(email, proxy)
    verifier.connect!
    verifier.verify!
	end

  # sets up configs with t
	def self.config(&block)
    if block_given?
      block.call(EmailVerifier::Config)
    else
      EmailVerifier::Config
    end
	end
end