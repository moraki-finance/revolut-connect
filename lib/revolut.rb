# frozen_string_literal: true

require "faraday"
require "faraday/retry"

require_relative "revolut/middlewares/catch_error"
require_relative "revolut/version"
require_relative "revolut/http"
require_relative "revolut/client"
require_relative "revolut/resources/resource"
Dir[File.join(__dir__, "revolut", "resources", "*.rb")].each { |file| require file }

module Revolut
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class NotImplementedError < Error; end

  class SignatureVerificationError < Error; end

  class Configuration
    attr_accessor :request_timeout, :global_headers, :environment, :token_duration, :scope, :auth_json, :api_version
    attr_writer :client_id, :signing_key, :iss, :authorize_redirect_uri

    DEFAULT_API_VERSION = "1.0"
    DEFAULT_ENVIRONMENT = "sandbox"
    DEFAULT_REQUEST_TIMEOUT = 120
    DEFAULT_TOKEN_DURATION = 120 # 2 minutes

    def initialize
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @global_headers = {}
      @client_id = ENV["REVOLUT_CLIENT_ID"]
      @signing_key = ENV["REVOLUT_SIGNING_KEY"]&.gsub("\\n", "\n")
      @iss = ENV.fetch("REVOLUT_ISS", "example.com")
      @authorize_redirect_uri = ENV["REVOLUT_AUTHORIZE_REDIRECT_URI"]
      @token_duration = ENV.fetch("REVOLUT_TOKEN_DURATION", DEFAULT_TOKEN_DURATION)
      @auth_json = ENV["REVOLUT_AUTH_JSON"]
      @scope = ENV["REVOLUT_SCOPE"]
      @api_version = ENV.fetch("REVOLUT_API_VERSION", DEFAULT_API_VERSION)
      @environment = ENV.fetch("REVOLUT_ENVIRONMENT", DEFAULT_ENVIRONMENT).to_sym
    end

    def client_id
      @client_id || (raise ConfigurationError, "Revolut client_id missing!")
    end

    def signing_key
      @signing_key || (raise ConfigurationError, "Revolut signing_key missing!")
    end

    def iss
      @iss || (raise ConfigurationError, "Revolut iss missing!")
    end

    def authorize_redirect_uri
      @authorize_redirect_uri || (raise ConfigurationError, "Revolut authorize_redirect_uri missing!")
    end
  end

  class << self
    attr_writer :config

    def config
      @config ||= Revolut::Configuration.new
    end

    def env
      config.environment
    end

    def sandbox?
      env == :sandbox
    end

    def configure
      yield(config)
    end
  end
end

# Load the authentication information from the environment variable REVOLUT_AUTH_JSON right away if possible.
Revolut::Auth.load_from_env
