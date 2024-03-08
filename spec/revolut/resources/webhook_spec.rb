RSpec.describe Revolut::Webhook do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resources_name" do
    expect(described_class.resources_name).to eq "webhooks"
  end

  it "#http_client - uses 2.0 api version" do
    Revolut.config.environment = :sandbox # Make sure it's sandbox. Just in case some other test set it to prod.
    expect(described_class.http_client.base_uri).to eq "https://sandbox-b2b.revolut.com/api/2.0/"
  end

  describe "#rotate_signing_secret" do
    it "rotates the signing secret" do
      allow(described_class.http_client).to receive(:post).with("/webhooks/1/rotate-signing-secret", data: {expiration_period: "P7D"}).and_return(
        OpenStruct.new(
          body: {
            "id" => "c6db947e-e9ce-41c2-b445-02e6eb741d21",
            "url" => "https://www.example.com",
            "events" => ["TransactionCreated", "PayoutLinkCreated"],
            "signing_secret" => "wsk_4jETWMz1g1b37gCONjNp84t2KSSIT7dK"
          }
        )
      )

      webhook = described_class.rotate_signing_secret(1, expiration_period: "P7D")

      expect(webhook).to be_a(Revolut::Webhook)
      expect(webhook).to have_attributes(
        id: "c6db947e-e9ce-41c2-b445-02e6eb741d21",
        url: "https://www.example.com",
        signing_secret: "wsk_4jETWMz1g1b37gCONjNp84t2KSSIT7dK"
      )
    end
  end

  describe "#failed_events" do
    it "returns failed events" do
      allow(described_class.http_client).to receive(:get).with("/webhooks/1/failed-events").and_return(
        OpenStruct.new(
          body: [{"id" => "c6db947e-e9ce-41c2-b445-02e6eb741d21"}]
        )
      )

      events = described_class.failed_events(1)

      expect(events.first).to be_a(Revolut::WebhookEvent)
      expect(events.first).to have_attributes(id: "c6db947e-e9ce-41c2-b445-02e6eb741d21")
    end
  end
end
