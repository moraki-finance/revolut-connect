RSpec.describe Revolut::Payment do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "pay"
  end

  it "only" do
    expect(described_class.send(:only)).to eq [:create]
  end

  it "#transactions" do
    expect(described_class.transactions).to eq(Revolut::Transaction)
  end

  it "#def_delegators" do
    allow(Revolut::Transaction).to receive(:list).and_return("list")
    allow(Revolut::Transaction).to receive(:retrieve).and_return("retrieve")
    allow(Revolut::Transaction).to receive(:delete).and_return("delete")

    expect(described_class.list).to eq("list")
    expect(described_class.retrieve).to eq("retrieve")
    expect(described_class.delete).to eq("delete")
  end
end
