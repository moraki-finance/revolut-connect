# Helper middleware only intended to be used in the console.
# The idea is to have a fast extraction of the API error message from the response body.

module Revolut
  module Middleware
    class CatchError < Faraday::Middleware
      def on_complete(env)
        raise_error_middleware.on_complete(env)
      rescue Faraday::Error => e
        raise e, JSON.parse(e.response[:body])["message"]
      end

      private

      def raise_error_middleware
        @raise_error_middleware ||= Faraday::Response::RaiseError.new
      end
    end
  end
end

Faraday::Response.register_middleware catch_error: Revolut::Middleware::CatchError
