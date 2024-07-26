RSpec.describe Revolut::ForeignExchange do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "exchange"
  end

  it "only" do
    expect(described_class.send(:only)).to eq [:shallow]
  end

  it "#rate_resource" do
    expect(described_class.rate_resource).to eq(Revolut::Rate)
  end

  it "#def_delegators" do
    allow(Revolut::Rate).to receive(:rate).and_return("rate")

    expect(described_class.rate).to eq("rate")
  end

  it "returns a ForeignExchange" do
    body = {
      request_id: "49c6a48b-6b58-40a0-b974-0b8c4888c8a7",
      from: {
        account_id: "8fe12333-5b27-4ad5-896c-38a25673fcc8",
        currency: "USD"
      },
      to: {
        account_id: "b4a3bcd2-c1dd-47cc-ac50-40cdb5856d42",
        currency: "GBP",
        amount: 10
      },
      reference: "exchange"
    }

    allow(described_class.http_client)
      .to receive(:post)
      .with("/exchange", data: body)
      .and_return(OpenStruct.new(body: {state: "completed"}))

    exchange = described_class.exchange(**body)

    expect(exchange).to be_a(Revolut::ForeignExchange)
    expect(exchange).to have_attributes(state: "completed")
  end
end
