RSpec.describe Revolut::Auth do
  let(:access_token_data) { token_exchange_response }
  let(:authorization_code) { "fake_code" }
  let(:refresh_token) { "fake_refresh_token" }

  before do
    stub_token_exchange(authorization_code:)
    stub_token_refresh(refresh_token:)
    described_class.clear
  end

  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "is shallow" do
    expect(described_class.send(:only)).to eq [:shallow]
  end

  describe ".exchange" do
    it "exchanges authorization code for access token and loads auth data" do
      auth = described_class.exchange(authorization_code:)

      expect(auth).to be_a(described_class)
      expect(described_class.access_token).to eq access_token_data[:access_token]
      expect(described_class.token_type).to eq access_token_data[:token_type]
      expect(described_class.expires_at).to eq Time.at(Time.now.to_i + access_token_data[:expires_in]).utc.to_datetime
      expect(described_class.refresh_token).to eq access_token_data[:refresh_token]
    end
  end

  describe ".refresh" do
    context "when expired" do
      it "refreshes the access token" do
        described_class.load(JSON.parse(access_token_data.merge(access_token: "old_token").to_json))
        expect(described_class.access_token).to eq("old_token")
        allow(described_class).to receive(:expired?).and_return(true)

        refreshed_auth = described_class.refresh

        expect(refreshed_auth).to be_a(described_class)
        expect(described_class.access_token).to eq("fake_access_token")
      end
    end

    context "when not expired but force refresh" do
      it "force refreshes the access token" do
        described_class.load(JSON.parse(access_token_data.merge(access_token: "old_token").to_json))
        allow(described_class).to receive(:expired?).and_return(false)

        refreshed_auth = described_class.refresh(force: true)

        expect(refreshed_auth).to be_a(described_class)
        expect(described_class.access_token).to eq("fake_access_token")
      end
    end
  end

  describe ".access_token" do
    context "when not authorized" do
      it "raises NotAuthorizedError" do
        described_class.load(JSON.parse(access_token_data.merge(access_token: nil).to_json))
        expect { described_class.access_token }.to raise_error(
          Revolut::Auth::NotAuthorizedError,
          "You need to authorize your app to access the Revolut business account of the user\n" \
            "Please visit #{Revolut::Auth.authorize_url} to get an authorization code that you can then use with the Revolut::Auth.retrieve method to get an access token."
        )
      end
    end

    context "when authorized" do
      it "returns the access token" do
        described_class.load(JSON.parse(access_token_data.to_json))

        expect(described_class.access_token).to eq("fake_access_token")
      end
    end
  end

  describe ".load_from_env" do
    context "when config is set" do
      before do
        Revolut.config.auth_json = access_token_data.to_json
      end

      it "loads auth data from env" do
        described_class.load_from_env

        expect(described_class.authenticated?).to eq(true)
      end
    end

    context "when config is not set" do
      before do
        Revolut.config.auth_json = nil
      end

      it "does nothing" do
        expect { described_class.load_from_env }.not_to change { described_class.authenticated? }
      end
    end
  end

  describe "#authorize_url" do
    before do
      Revolut.config.environment = :sandbox
    end

    it "builds the authorize url" do
      expect(Revolut::Auth.authorize_url).to eq(
        "https://sandbox-business.revolut.com/app-confirm?client_id=fake_client_id&redirect_uri=https://example.com&response_type=code#authorise"
      )
    end

    context "when there's a scope defined" do
      before do
        Revolut.config.scope = "READ,WRITE"
      end

      it "adds the scope" do
        expect(Revolut::Auth.authorize_url).to eq(
          "https://sandbox-business.revolut.com/app-confirm?client_id=fake_client_id&redirect_uri=https://example.com&response_type=code&scope=READ,WRITE#authorise"
        )
      end

      context "when the environment is production " do
        before do
          Revolut.config.environment = :production
        end

        it "use the production host" do
          expect(Revolut::Auth.authorize_url).to eq(
            "https://business.revolut.com/app-confirm?client_id=fake_client_id&redirect_uri=https://example.com&response_type=code&scope=READ,WRITE#authorise"
          )
        end
      end
    end
  end
end
