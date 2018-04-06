# EmailVerifier

Helper utility to validate if a given email address is real.

This gem does a complete validation for an email - from checking email format to actually connecting with a given mail server and asking if the email in question is real.

It uses telnet protocol to perform the validation. Telnet was used as it gives the power to try connections with smtp server on different ports rather than just 25. This gem considers port - 25, 587, 465, 2525 into consideration while trying connections.

Most of the email servers black list the ip if one continously bombards the email server with requests. Going further, you would not be able to validate the email, until and unless you get you ip removed from the blacklist. This gem has provision for using proxies hiding you server's identity behind it.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'email_verifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email_verifier

## Usage

To get info about realness of given email address, email_verifier connects with a mail server that email's domain points to and pretends to send an email. Some smtp servers will not allow you to do this if you will not present yourself as a real user.

First thing you need to set up is placing something like this either in initializer or in application.rb file:

```
EmailVerifier.config do |config|
  config.verifier_email = "realname@realdomain.com"
end
```

Then, one can use it like this - 

```
EmailVerifier.check!(email_to_be_tested)
```

This method returns true, if the email is correct, otherwise it raises an exception defining what went wrong while validating the email.

One can hide the server's ip by using proxy like this -

```
EmailVerifier.check!(email_to_be_tested, {'Host': '80.211.x.xxx', 'Port': 8080})
```

This would seemlessly validate the email using the provided proxy server.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your-username/email_verifier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
