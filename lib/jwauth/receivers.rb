module Jwauth
  class Receivers
    class << self
      def header(header_name)
        ->(request) { request.headers[header_name].try(:split, ' ').try(:last) }
      end

      def param(param_name)
        ->(request) { request.params[param_name] }
      end
    end
  end
end
