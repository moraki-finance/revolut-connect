RSpec.describe Revolut::Transfer do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "transfer"
  end

  it "only" do
    expect(described_class.send(:only)).to eq [:create]
  end

  it "#transfer_reasons" do
    expect(described_class.transfer_reason).to eq(Revolut::TransferReason)
  end

  it "#def_delegator" do
    allow(Revolut::TransferReason).to receive(:list).and_return("list")

    expect(described_class.list_reasons).to eq("list")
  end
end
