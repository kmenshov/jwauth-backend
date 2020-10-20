require 'jwt'

module Jwauth
  module Token
    def self.encode(payload: {}, fast_expiration: false, secret: Jwauth.secret, algorithm: Jwauth.algorithm)
      return '' if payload.blank?

      payload = payload.stringify_keys
      unless payload.key?('exp')
        payload['exp'] = Time.now.to_i + (fast_expiration ? Jwauth.fast_expiration : Jwauth.expiration)
      end
      JWT.encode(payload, secret, algorithm)
    end

    def self.decode(token, validate: true, secret: Jwauth.secret, algorithm: Jwauth.algorithm)
      return {} if token.blank?

      JWT.decode(token, secret, validate, algorithm: algorithm).first
    rescue JWT::DecodeError
      {}
    end
  end
end
