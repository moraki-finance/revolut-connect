require "forwardable"

module Revolut
  class ForeignExchange < Resource
    shallow

    class << self
      extend Forwardable

      def resource_name
        "exchange"
      end

      def exchange(**attrs)
        response = http_client.post("/#{resource_name}", data: attrs)

        new(response.body)
      end

      # Delegate rate to the rate resource
      def_delegators :rate_resource, :rate

      def rate_resource
        Revolut::Rate
      end
    end
  end
end
