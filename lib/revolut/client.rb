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
      api_version
      environment
      request_timeout
      global_headers
    ].freeze

    attr_reader(*CONFIG_KEYS, :base_uri)

    def initialize(**attrs)
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set(:"@#{key}", attrs[key] || Revolut.config.send(key))
      end

      @base_uri = (environment == :sandbox) ? "https://sandbox-b2b.revolut.com/api/#{api_version}/" : "https://b2b.revolut.com/api/#{api_version}/"
    end

    # Instance with all the defaults
    def self.instance
      @instance ||= new
    end
  end
end
