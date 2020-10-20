require 'test_helper'

class JwauthControllerTest < ActionDispatch::IntegrationTest
  test 'responds with 204 if not authorized' do
    post '/regenerate_token'

    assert_response :no_content
    assert_equal '', response.body
    assert_equal 'no-cache, no-store', response.headers['Cache-Control']
  end

  test 'responds with 204 if invalid JWT' do
    post '/regenerate_token', headers: { 'Authorization': 'JWT some nonsense' }

    assert_response :no_content
    assert_equal '', response.body
    assert_equal 'no-cache, no-store', response.headers['Cache-Control']
  end

  test 'responds with 204 if JWT expired' do
    jwt = Jwauth::Token.encode(payload: { id: 7, exp: 1.second.ago.to_i })

    post '/regenerate_token', headers: { 'Authorization': "JWT #{jwt}" }

    assert_response :no_content
    assert_equal '', response.body
    assert_equal 'no-cache, no-store', response.headers['Cache-Control']
  end

  test 'responds with 204 if JWT tampered' do
    jwt = Jwauth::Token.encode(payload: { id: 7, exp: 1.day.from_now.to_i })
    jwt[-7] = jwt[-7].next # tamper it just a little

    post '/regenerate_token', headers: { 'Authorization': "JWT #{jwt}" }

    assert_response :no_content
    assert_equal '', response.body
    assert_equal 'no-cache, no-store', response.headers['Cache-Control']
  end

  test 'renews JWT if it is valid' do
    hash = { id: 7, something_other: 'info', exp: 3.seconds.from_now.to_i }

    post '/regenerate_token', headers: { 'Authorization': "JWT #{Jwauth::Token.encode(payload: hash)}" }

    assert_response :ok
    assert_equal 'no-cache, no-store', response.headers['Cache-Control']

    new_hash = Jwauth::Token.decode(response.body).symbolize_keys

    assert new_hash[:exp] > (Time.now.to_i + Jwauth.expiration - 3.seconds.to_i)

    new_hash.delete(:exp)
    hash.delete(:exp)
    assert_equal hash, new_hash
  end
end
