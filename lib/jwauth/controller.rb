class JwauthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include Jwauth

  before_action :set_cache_header

  def regenerate_token
    new_hash = jwt_inbound_hash.stringify_keys
    new_hash.delete('exp') # reset expiration time
    new_token = jwt_outbound_token(payload: new_hash, fast_expiration: false)

    new_token.present? ? render(plain: new_token) : head(:no_content)
  rescue JWT::DecodeError
    head(:no_content)
  end

  private

  def set_cache_header
    response.set_header('Cache-Control', 'no-cache, no-store')
  end
end
