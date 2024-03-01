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
        base_uri: "https://sandbox-b2b.revolut.com/api/1.0/",
        environment: :sandbox,
        request_timeout: 120,
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
        max: 1,
        exceptions: [Faraday::UnauthorizedError],
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
        CatchError
      ].each do |middleware|
        expect(subject.builder.handlers).to include(middleware)
      end
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
      expect(response.body).to eq token_exchange_response.to_json
    end
  end

  describe "refresh_access_token" do
    let(:response) { client.refresh_access_token(refresh_token: "fake_refresh_token") }

    before do
      stub_token_refresh(refresh_token: "fake_refresh_token")
    end

    it "returns the response" do
      expect(response.body).to eq token_refresh_response.to_json
    end
  end
end
