module Revolut
  class Client
    include Revolut::HTTP

    CONFIG_KEYS = %i[
      client_id
      signing_key
      iss
      token_duration
      scope
      authorize_redirect_uri
      base_uri
      environment
      request_timeout
      global_headers
    ].freeze

    attr_reader(*CONFIG_KEYS)

    def self.instance
      @instance ||= new
    end

    private

    def initialize
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set(:"@#{key}", Revolut.config.send(key))
      end
    end
  end
end
