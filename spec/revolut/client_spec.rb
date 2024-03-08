RSpec.describe Revolut::Client do
  let(:client) { Revolut::Client.instance }
  let(:resource) { "resource" }
  let(:fake_response) { {fake_response: true} }

  describe ".initialize" do
    it "uses the default configuration" do
      expect(client).to have_attributes(
        client_id: "fake_client_id",
        signing_key: "fake_signing_key",
        iss: "example.com",
        authorize_redirect_uri: "https://example.com",
        api_version: "1.0",
        base_uri: "https://sandbox-b2b.revolut.com/api/1.0/",
        environment: :sandbox,
        request_timeout: 120,
        token_duration: 120,
        scope: nil,
        global_headers: {}
      )
    end
  end

  describe ".conn" do
    subject { client.send(:conn) }

    it "sets up the faraday connection timeout" do
      expect(subject.options).to have_attributes(
        timeout: 120
      )
    end

    it "sets up the required middlewares by default" do
      [
        Faraday::Request::Json,
        Faraday::Retry::Middleware,
        Faraday::Request::Authorization,
        Faraday::Response::Json,
        Faraday::Response::RaiseError
      ].each do |middleware|
        expect(subject.builder.handlers).to include(middleware)
      end
    end

    it "sets up the retry middleware" do
      options = subject.builder.handlers.find { |h| h == Faraday::Retry::Middleware }.instance_variable_get(:@args).first
      env = OpenStruct.new(request_headers: {})
      allow(Revolut::Auth).to receive(:refresh).with(force: true)
      allow(Revolut::Auth).to receive(:access_token).and_return("fake_access_token")
      expect(options).to match(
        exceptions: [Faraday::UnauthorizedError],
        # We're only retrying on Faraday::UnauthorizedError, so we should be good about retrying non idempotent methods like post and patch.
        methods: Faraday::Retry::Middleware::IDEMPOTENT_METHODS + %i[post patch],
        retry_block: anything # We're going to test this separately
      )
      options[:retry_block].call(env:, options: {}, retry_count: 0, exception: Faraday::UnauthorizedError.new, will_retry_in: 0)
      expect(env.request_headers["Authorization"]).to eq "Bearer fake_access_token"
    end

    it "sets up the authorization middleware" do
      options = subject.builder.handlers.find { |h| h == Faraday::Request::Authorization }.instance_variable_get(:@args)
      allow(Revolut::Auth).to receive(:access_token).and_return("fake_access_token")
      expect(options).to match_array([
        "Bearer",
        anything # We're going to test this separately
      ])
      expect(options[1].call).to eq "fake_access_token"
    end

    it "sets up the catch_error middleware when being on console" do
      ENV["CONSOLE"] = "true"
      [
        Faraday::Request::Json,
        Faraday::Retry::Middleware,
        Faraday::Request::Authorization,
        Faraday::Response::Json,
        Revolut::Middleware::CatchError
      ].each do |middleware|
        expect(subject.builder.handlers).to include(middleware)
      end
    end

    it "catches the error when console is true" do
      stub_authentication
      ENV["CONSOLE"] = "true"
      stub_resource(:get, resource, status: 400, response: {body: {message: "Some error happened"}})
      expect { client.get(resource) }.to raise_error(Faraday::BadRequestError, "Some error happened")
    end
  end

  describe "get" do
    let(:method) { :get }

    before do
      stub_authentication
    end

    it "returns the response" do
      stub_resource(method, resource, response: {body: fake_response})
      response = client.send(method, resource)
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in extra headers" do
      stub_resource(method, resource, response: {body: fake_response}, request: {headers: {"X-Extra-Header" => "value"}})
      response = client.send(method, resource, headers: {"X-Extra-Header" => "value"})
      expect(response.env.request_headers["X-Extra-Header"]).to eq "value"
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in query parameters" do
      stub_resource(method, resource, response: {body: fake_response}, query: {status: "completed"})
      response = client.send(method, resource, status: "completed")
      expect(response.body).to eq_as_json fake_response
    end
  end

  describe "post" do
    let(:method) { :post }
    let(:fake_response) { {fake_response: true} }

    before do
      stub_authentication
    end

    it "returns the response" do
      stub_resource(method, resource, response: {body: fake_response})
      response = client.send(method, resource)
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in extra headers" do
      stub_resource(method, resource, response: {body: fake_response}, request: {headers: {"X-Extra-Header" => "value"}})
      response = client.send(method, resource, headers: {"X-Extra-Header" => "value"})
      expect(response.env.request_headers["X-Extra-Header"]).to eq "value"
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in query parameters" do
      stub_resource(method, resource, response: {body: fake_response}, query: {status: "completed"})
      response = client.send(method, resource, status: "completed")
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in data" do
      stub_resource(method, resource, response: {body: fake_response}, request: {body: {"status" => "completed"}})
      response = client.send(method, resource, data: {status: "completed"})
      expect(response.body).to eq_as_json fake_response
    end
  end

  describe "patch" do
    let(:method) { :patch }
    let(:fake_response) { {fake_response: true} }

    before do
      stub_authentication
    end

    it "returns the response" do
      stub_resource(method, resource, response: {body: fake_response})
      response = client.send(method, resource)
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in extra headers" do
      stub_resource(method, resource, response: {body: fake_response}, request: {headers: {"X-Extra-Header" => "value"}})
      response = client.send(method, resource, headers: {"X-Extra-Header" => "value"})
      expect(response.env.request_headers["X-Extra-Header"]).to eq "value"
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in query parameters" do
      stub_resource(method, resource, response: {body: fake_response}, query: {status: "completed"})
      response = client.send(method, resource, status: "completed")
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in data" do
      stub_resource(method, resource, response: {body: fake_response}, request: {body: {"status" => "completed"}})
      response = client.send(method, resource, data: {status: "completed"})
      expect(response.body).to eq_as_json fake_response
    end
  end

  describe "delete" do
    let(:method) { :delete }

    before do
      stub_authentication
    end

    it "returns the response" do
      stub_resource(method, resource, response: {body: fake_response})
      response = client.send(method, resource)
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in extra headers" do
      stub_resource(method, resource, response: {body: fake_response}, request: {headers: {"X-Extra-Header" => "value"}})
      response = client.send(method, resource, headers: {"X-Extra-Header" => "value"})
      expect(response.env.request_headers["X-Extra-Header"]).to eq "value"
      expect(response.body).to eq_as_json fake_response
    end

    it "allows to pass in query parameters" do
      stub_resource(method, resource, response: {body: fake_response}, query: {status: "completed"})
      response = client.send(method, resource, status: "completed")
      expect(response.body).to eq_as_json fake_response
    end
  end

  describe "get_access_token" do
    let(:response) { client.get_access_token(authorization_code: "fake_code") }

    before do
      stub_token_exchange(authorization_code: "fake_code")
    end

    it "returns the response" do
      expect(response.body).to eq_as_json token_exchange_response
    end
  end

  describe "refresh_access_token" do
    let(:response) { client.refresh_access_token(refresh_token: "fake_refresh_token") }

    before do
      stub_token_refresh(refresh_token: "fake_refresh_token")
    end

    it "returns the response" do
      expect(response.body).to eq_as_json token_refresh_response
    end
  end

  describe "base_ur" do
    context "when the environment is sandbox" do
      it "returns the sandbox base_uri" do
        expect(client.base_uri).to eq "https://sandbox-b2b.revolut.com/api/1.0/"
      end
    end

    context "when the environment is production" do
      let(:client) { Revolut::Client.new(environment: :production) }

      it "returns the production base_uri" do
        expect(client.base_uri).to eq "https://b2b.revolut.com/api/1.0/"
      end
    end
  end
end
