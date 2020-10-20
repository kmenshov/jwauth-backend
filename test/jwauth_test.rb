require 'test_helper'

class JwauthTest < ActionController::TestCase
  tests JwauthTestController

  JWAUTH_CONFIG_PARAMS = %i[receivers session_data algorithm expiration fast_expiration secret]

  def set_config
    @jwauth_old_config = {}
    Jwauth.configure do |config, receivers|
      JWAUTH_CONFIG_PARAMS.each do |param|
        @jwauth_old_config[param] = config.send(param)
      end

      config.receivers = [
        receivers.param('jwt'),
        receivers.header('HTTP_AUTHORIZATION'),
        receivers.param('jwt2'),
      ]
      config.session_data = 'session_source_data'
    end
  end

  def restore_config
    @jwauth_old_config.each do |key, value|
      Jwauth.send("#{key}=", value)
    end
  end

  def reset_jwt
    @controller.instance_variable_set(:@jwt_inbound_token, nil)
  end

  setup do
    set_config
  end

  teardown do
    restore_config
  end

  test 'receives JWT in accordance with config priority' do
    request.headers.merge!({ 'HTTP_AUTHORIZATION': 'JWT jwt_from_header' })

    get :index, params: { 'jwt' => 'jwt_from_url_1', 'jwt2' => 'jwt_from_url_2' }
    assert_equal 'jwt_from_url_1', @controller.jwt_inbound_token

    reset_jwt

    # params are case-sensitive
    get :index, params: { 'jWt' => 'jwt_from_url_1', 'jwt2' => 'jwt_from_url_2' }
    assert_equal 'jwt_from_header', @controller.jwt_inbound_token

    reset_jwt

    request.headers.merge!({ 'HTTP_AUTHORIZATION': nil })
    get :index, params: { 'jWt' => 'jwt_from_url_1', 'jwt2' => 'jwt_from_url_2' }
    assert_equal 'jwt_from_url_2', @controller.jwt_inbound_token
  end

  test 'decodes JWT with and without validation' do
    jwt_hash = { 'some' => 'data' }
    jwt = Jwauth::Token.encode(payload: jwt_hash)

    request.headers.merge!({ 'HTTP_AUTHORIZATION': "JWT #{jwt}" })
    get :index

    assert_equal jwt_hash, @controller.jwt_inbound_hash.except('exp')
    assert_equal({}, @controller.jwt_inbound_hash(secret: 'wrong'))
    assert_equal jwt_hash, @controller.jwt_inbound_hash(secret: 'wrong', validate: false).except('exp')
  end

  test 'can take session source data from a method or a proc' do
    assert_equal @controller.session_source_data, @controller.jwt_outbound_hash

    Jwauth.session_data = lambda do |controller|
      original = controller.session_source_data
      original.merge({ 'modified' => 'Inside a Lambda' })
    end

    assert_equal @controller.session_source_data.merge({ 'modified' => 'Inside a Lambda' }), @controller.jwt_outbound_hash
  end

  test 'generates JWT HTML meta tag with short expiration time' do
    tag = @controller.jwt_meta_tag
    token = tag[tag.index('content="') + 9 ... tag.index('">')]
    jwt_hash = Jwauth::Token.decode(token)
    expiration = jwt_hash.delete('exp')

    assert_equal 0, tag.index('<meta name="token" content="')
    assert_equal @controller.session_source_data, jwt_hash
    assert (expiration > Time.now.to_i) && (expiration <= Time.now.to_i + Jwauth.fast_expiration)
  end
end
