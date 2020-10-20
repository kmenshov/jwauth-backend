require 'jwauth/railtie'

require 'jwauth/receivers'
require 'jwauth/senders'
require 'jwauth/token'

require 'jwauth/controller'
require 'jwauth/routes'

module Jwauth
  include Senders
  def self.included(base)
    base.class_eval do
      Senders.instance_methods(false).each do |instance_method|
        helper_method instance_method
      end
    end
  end

  def self.define_config_option(name, default_value)
    send :mattr_accessor, name.to_sym
    send("#{name}=", default_value)
  end

  define_config_option :algorithm,             'HS256'
  define_config_option :expiration,            1.day.to_i
  define_config_option :fast_expiration,       1.minute.to_i
  define_config_option :receivers,             []
  define_config_option :regenerate_token_path, '/regenerate_token'
  define_config_option :secret,                SecureRandom.hex(64)
  define_config_option :session_data,          'session_data'

  def self.configure
    yield self, Receivers
  end

  def jwt_inbound_token
    @jwt_inbound_token ||= Jwauth.receivers.lazy.map { |r| r.call(request) }.find(&:present?)
  end

  def jwt_inbound_hash(validate: true, secret: Jwauth.secret, algorithm: Jwauth.algorithm)
    Token.decode(
      jwt_inbound_token,
      validate: validate,
      secret: secret,
      algorithm: algorithm
    )
  end

  def jwt_outbound_hash
    Jwauth.session_data.is_a?(Proc) ? Jwauth.session_data.call(self) : send(Jwauth.session_data.to_s)
  end

  def jwt_outbound_token(payload: nil, fast_expiration: false, secret: Jwauth.secret, algorithm: Jwauth.algorithm)
    Token.encode(
      payload: payload || jwt_outbound_hash,
      fast_expiration: fast_expiration,
      secret: secret,
      algorithm: algorithm
    )
  end
end
