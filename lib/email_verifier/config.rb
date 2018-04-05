module EmailVerifier
  module Config
    class << self
      attr_accessor :verifier_email

      def configure
        @verifier_email = "utkarsh@nonexistant.com" # dummy email
      end
    end

    self.configure
  end
end