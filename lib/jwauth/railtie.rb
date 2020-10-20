module Jwauth
  class Railtie < ::Rails::Railtie
    initializer 'jwauth_railtie.configure_rails_initialization' do |app|
      Jwauth.configure do |config, receivers|
        config.secret = app.try(:secrets).try(:secret_key_base) || config.secret || SecureRandom.hex(64)
        config.receivers = [
          receivers.param('jwt'),
          receivers.header('HTTP_AUTHORIZATION')
        ]
      end
    end
  end
end
