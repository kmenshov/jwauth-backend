require 'test_helper'

class JwauthConfigTest < ActionController::TestCase
  setup do
    @initializer = Jwauth::Railtie.initializers.find { |i| i.name == 'jwauth_railtie.configure_rails_initialization' }
  end
  attr_reader :initializer

  test 'sets the secret to the secret_key_base by default' do
    secret_key_base = Rails.application.secrets.secret_key_base
    assert_not_nil secret_key_base

    assert_equal secret_key_base, Jwauth.secret
  end

  test 'if secret_key_base is nil sets the secret to a random SecureHash string' do
    # remember current config
    secret_key_base = Rails.application.secrets.secret_key_base
    jwauth_secret = Jwauth.secret

    Rails.application.secrets.secret_key_base = nil
    Jwauth.secret = nil
    initializer.run

    assert_not_nil Jwauth.secret
    assert_not_equal secret_key_base, Jwauth.secret
    assert_not_equal jwauth_secret,   Jwauth.secret

    assert Jwauth.secret.is_a?(String)
    assert_equal 128, Jwauth.secret.length

    # restore previous config
    Rails.application.secrets.secret_key_base = secret_key_base
    Jwauth.secret = jwauth_secret
  end
end
