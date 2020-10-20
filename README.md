# Jwauth
Short description and motivation.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'jwauth'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install jwauth
```

## Usage

In ApplicationController:
```ruby
# app/controllers/application_controller.rb
include Jwauth
```

In Application Layout:
```html
<!-- app/views/layouts/application.html.erb -->
<head>
  <%= jwt_meta_tag %>
</head>
```

In Routes:
```ruby
# config/routes.rb
jwauth_routes
```

Custom configuration (optional):
```ruby
# config/initializers/jwauth.rb
Jwauth.configure do |config, receivers|
  config.receivers = [
    receivers.param('jwt'),
    receivers.header('HTTP_AUTHORIZATION'),
  ]
  # etc...
end
```

Then in controllers you will get the following methods to use in your session:
`jwt_inbound_token` - raw inbound token;
`jwt_inbound_hash`  - decoded hash (or empty hash if JWT expired, wrong secret, etc.).

Your HTML controller(s) should implement a `#session_data` method which should return a hash. This hash will be encoded into a JWT token and sent to the front-end to be used in Ajax requests.

The `session_data` method name can be changed via Jwauth's `config.session_data =` which can take a string or a Proc. The Proc will receive the calling controller as parameter, and its return value will be used as the session data hash.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
