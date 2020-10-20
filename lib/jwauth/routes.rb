module ActionDispatch::Routing # rubocop:disable Style/ClassAndModuleChildren
  class Mapper
    def jwauth_routes(path_name = Jwauth.regenerate_token_path)
      post path_name, to: 'jwauth#regenerate_token'
    end
  end
end
