RSpec.describe Revolut::Rate do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resource_name" do
    expect(described_class.resource_name).to eq "rate"
  end

  it "is shallow" do
    expect(described_class.send(:only)).to eq [:shallow]
  end

  it "returns a Rate" do
    params = {from: "EUR", to: "USD", amount: 100}

    allow(described_class.http_client)
      .to receive(:get)
      .with("/rate", params)
      .and_return(OpenStruct.new(body: {rate: 1.1}))

    rate = described_class.rate(**params)

    expect(rate).to be_a(Revolut::Rate)
    expect(rate).to have_attributes(rate: 1.1)
  end
end
