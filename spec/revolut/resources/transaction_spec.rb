RSpec.describe Revolut::Transaction do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "only" do
    expect(described_class.send(:only)).to eq [:list, :retrieve, :delete]
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "transaction"
  end

  it "#resources_name" do
    expect(described_class.send(:resources_name)).to eq "transactions"
  end
end
