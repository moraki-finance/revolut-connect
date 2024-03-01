RSpec.describe Revolut::TransferReason do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "only" do
    expect(described_class.send(:only)).to eq [:list]
  end

  it "#resources_name" do
    expect(described_class.send(:resources_name)).to eq "transfer-reasons"
  end
end
