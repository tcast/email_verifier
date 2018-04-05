require 'pry'
require 'dnsruby'
require 'net/telnet'

module EmailVerifier
	class Checker
		VALID_EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
		PORTS = [25, 587, 465, 2525]
		SUCCESS_REGEX = /250/

		def initialize(email, proxy = nil)
			@email = email
			_, @domain  = @email.split("@")

			@proxy = proxy
			@telnet_conn = nil

			check_email_format

			@servers = list_mxs @domain
		end

		# tries connecting to smtp server on various ports using telnet.
		def connect!
	    begin
			  server = next_server
			  raise EmailVerifier::OutOfMailServersException.new("Unable to connect to any one of mail servers for #{@email}") unless server

			  host = server[:address]
			  PORTS.each do |port|
			  	begin
			  		if proxy
			  			@telnet_conn = Net::Telnet.new('Host' => host, 'Port' => port, 'Prompt' => /^[0-9]{3}\s.*$/, 'Timeout' => 5, "Proxy" => proxy, "Telnetmode" => false)
			  		else
			  			@telnet_conn = Net::Telnet.new('Host' => host, 'Port' => port, 'Prompt' => /^[0-9]{3}\s.*$/, 'Timeout' => 5, "Telnetmode" => false)
			  		end

			  		puts "Connected successfully to #{host} on port #{port}"
			  		@telnet_conn.cmd('') # to release the stale server response, need to fix after wards
			  		break
			  	rescue 
			  		puts "Cannot connect to host: #{host} on port #{port}"
			  		next
			  	end
			  end

			  raise unless @telnet_conn
			rescue EmailVerifier::OutOfMailServersException => e
      	raise EmailVerifier::OutOfMailServersException, e.message
			rescue => e
				retry # pick next server 
			end
	  end

	  # verifies an email with a three step process
	  # sends hello message to the server to establish connection
	  # sends mail_from command to smtp server
	  # sends rcpt_to command to the smtp server
		def verify!
			say_hello
			mailfrom('stealout@gmail.com') # needs to be picked up from the configurations.
			result = rcptto(@email)

			@telnet_conn.cmd("QUIT")
			result
		end

		private

		# checks if there is an existing telnet connection to smtp server
		def ensure_connected
			raise EmailVerifier::NotConnectedException.new("You have to connect first") if @telnet_conn.nil?
		end

		# sends hello message to the server initiating a connection
		def say_hello
			ensure_connected

			me = Socket.gethostname

			@telnet_conn.cmd("HELO #{me}") do |chunk|
				puts "sending hello message to the server => #{chunk}"
				raise unless SUCCESS_REGEX.match(chunk)
			end
			@telnet_conn.cmd("HELO sample_command")
			puts 'response picked from server to correct the response sequence...needs fix later'
		rescue => e
			puts e
			raise EmailVerifier::FailureException.new "can't say hello to server ......"
		end

		def mailfrom(address)
		  ensure_connected

		  @telnet_conn.cmd("MAIL FROM:<#{address}>") do |chunk|
		  	puts "in from address => #{chunk}"
		  	raise chunk unless SUCCESS_REGEX.match(chunk)
		  end
		rescue => e
			raise EmailVerifier::FailureException.new "Failed for 'from address' command execution with => #{e}"
		end

		def rcptto(address)
		  ensure_connected

		  @telnet_conn.cmd("RCPT TO:<#{address}>") do |chunk|
		  	puts "in to address => #{chunk}"
		  	raise chunk unless SUCCESS_REGEX.match(chunk)
		  end
		  true
		rescue => e
			raise EmailVerifier::FailureException.new "Failed for 'to address' command execution with => #{e}"
		end

		def check_email_format
			raise EmailVerifier::EmailRequiredException.new('Email is required.') if @email.nil?

			email_valid = VALID_EMAIL_REGEX.match(@email)
			raise EmailVerifier::EmailFormatIncorrectException.new('Email format Incorrect.') unless email_valid
		end

	  # every email domain has some mail exchangers[MX]
		# responsible for accepting email messages on behalf of a recipient's domain
		# 
		# there could be multiple mail exchangers for a particular email domain
		#
		# This will help -
		# http://mxlookup.online-domain-tools.com/
		# mxs - mail exchanger lookups
		def list_mxs(domain)
	    return [] unless domain

	    res = Dnsruby::DNS.new
	    mxs = []

	    res.each_resource(domain, 'MX') do |rr|
	      mxs << { priority: rr.preference, address: rr.exchange.to_s }
	    end

	    raise EmailVerifier::NoMailServerException if mxs.empty?

	    mxs.sort_by { |mx| mx[:priority] }
	  rescue Dnsruby::NXDomain
	    raise EmailVerifier::NoMailServerException.new("#{domain} does not exist") 
	  rescue EmailVerifier::NoMailServerException
	  	raise EmailVerifier::NoMailServerException.new("No mail server for #{@email}")
	  end

	  def next_server
	  	@servers.shift
	  end

	  # returns a net telnet proxy object
	  def proxy
	  	return nil if (@proxy['Host'].nil? || @proxy['Port'].nil?)

	  	Net::Telnet.new('Host' => @proxy['host'], 'Port' => @proxy['port'])
	  end
	end
end
