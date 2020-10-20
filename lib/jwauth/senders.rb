module Jwauth
  module Senders
    def jwt_meta_tag
      content = jwt_outbound_token(fast_expiration: true)
      "<meta name=\"token\" content=\"#{content}\">".html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
