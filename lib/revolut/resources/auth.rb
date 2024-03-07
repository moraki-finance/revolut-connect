require "jwt"

module Revolut
  class Auth < Resource
    shallow

    class NotAuthorizedError < StandardError
      def initialize
        super(
          "You need to authorize your app to access the Revolut business account of the user\n" \
            "Please visit #{Revolut::Auth.authorize_url} to get an authorization code that you can then use with the Revolut::Auth.retrieve method to get an access token."
        )
      end
    end

    class << self
      attr_accessor :token_type, :refresh_token
      attr_writer :access_token, :expires_at

      # Generates the authorization URL for the Revolut API.
      # Use this URI to redirect the user to Revolut's authorization page
      # to authorize your app to access her business account.
      #
      # @return [String] The authorization URL.
      def authorize_url
        URI::HTTPS.build(
          host: authorize_uri_host,
          path: "/app-confirm",
          query: "client_id=#{Revolut.config.client_id}&redirect_uri=#{Revolut.config.authorize_redirect_uri}&response_type=code" + (Revolut.config.scope ? "&scope=#{Revolut.config.scope}" : "")
        ).to_s + "#authorise"
      end

      # Exchanges the authorization code for an access token.
      #
      # @param authorization_code [String] The authorization code to retrieve the access token.
      # @return [Auth] The newly created Revolut::Auth object.
      def exchange(authorization_code:)
        auth_json = http_client.get_access_token(authorization_code:).body
        load(auth_json)
        new(auth_json)
      end

      # Loads authentication data from a JSON object.
      #
      # @param auth_json [Hash] The JSON object containing authentication data.
      # @return [void]
      def load(auth_json)
        @access_token = auth_json["access_token"]
        @token_type = auth_json["token_type"]
        @expires_at = Time.now.to_i + auth_json["expires_in"]
        @refresh_token = auth_json["refresh_token"]
      end

      # Returns the access token too access the Revolut API.
      # Raises Revolut::Auth::NotAuthorizedError if the access token is not set.
      # Refreshes the access token if it has expired.
      #
      # @return [String] The access token.
      def access_token
        # If there's no token set in the authorization class, it means that we're trying to
        # access the API without having gone through the authorization process.
        raise Revolut::Auth::NotAuthorizedError if @access_token.nil?

        refresh if expired?

        @access_token
      end

      # Refreshes the access token if it has expired or if force is set to true.
      #
      # @param force [Boolean] Whether to force refresh the access token.
      # @return [Revolut::Resources::Auth] The refreshed authentication object.
      def refresh(force: false)
        return unless expired? || force

        new(http_client.refresh_access_token(refresh_token:).body).tap do |refreshed_auth|
          @access_token = refreshed_auth.access_token
          @token_type = refreshed_auth.token_type
          @expires_at = Time.now.to_i + refreshed_auth.expires_in
        end
      end

      # Returns the expiration date and time of the authentication token.
      #
      # @return [DateTime] The expiration date and time.
      def expires_at
        Time.at(@expires_at).utc.to_datetime
      end

      # Checks if the access_token has expired.
      #
      # Returns:
      # - true if the access_token has expired
      # - false otherwise
      def expired?
        expires_at && Time.now.to_i >= @expires_at
      end

      # Checks if the user is authenticated.
      #
      # Returns:
      # - true if the access token is present and not expired
      # - false otherwise
      def authenticated?
        !@access_token.nil? && !expired?
      end

      # Loads authentication information from the configuration auth_json.
      #
      # If the access token is not already set and auth_json config is present,
      # this method loads the JSON data from the config variable and calls the load method to set the authentication information.
      #
      # Example:
      #   auth.load_from_env
      #
      # @return [void]
      def load_from_env
        env_json = Revolut.config.auth_json

        return unless @access_token.nil? && env_json

        load(JSON.parse(env_json))
      end

      # Clears the authentication information.
      def clear
        @access_token = nil
        @token_type = nil
        @expires_at = nil
        @refresh_token = nil
      end

      private

      def authorize_uri_host
        Revolut.sandbox? ? "sandbox-business.revolut.com" : "business.revolut.com"
      end
    end
  end
end
