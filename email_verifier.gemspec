# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "email_verifier/version"

Gem::Specification.new do |spec|
  spec.name          = "email_verifier"
  spec.version       = EmailVerifier::VERSION
  spec.authors       = ["Utkarsh Rai"]
  spec.email         = ["utkarshrai003@gmail.com"]

  spec.summary       = "Ruby gem to verify email address using telnet"
  spec.description   = "Ruby gem to verify email addeess using telnet"
  spec.homepage      = "https://www.example.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = Dir["lib/email_verifier.rb", "lib/email_verifier/**/*.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "dnsruby", "~> 1.60.2"
  spec.add_runtime_dependency "net-telnet", "~> 0.1.1"
  spec.add_development_dependency "pry"
end
