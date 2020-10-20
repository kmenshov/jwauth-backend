require "test_helper"

class JwauthRoutesTest < ActionDispatch::IntegrationTest
  test 'routes to #regenerate_token' do
    assert_routing({ path: Jwauth.regenerate_token_path, method: 'post' },
                   { controller: 'jwauth', action: 'regenerate_token' })
  end
end
