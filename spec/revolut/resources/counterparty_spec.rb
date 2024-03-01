RSpec.describe Revolut::Counterparty do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resources_name" do
    expect(described_class.resources_name).to eq "counterparties"
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "counterparty"
  end

  it "coerce_with" do
    expect(described_class.send(:coerce_with)).to eq({accounts: Revolut::BankAccount})
  end

  it "not_allowed_to" do
    expect(described_class.send(:not_allowed_to)).to eq [:update]
  end
end
