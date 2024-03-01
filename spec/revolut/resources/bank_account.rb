RSpec.describe Revolut::BankAccount do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "is shallow" do
    expect(described_class.send(:only)).to eq [:shallow]
  end
end
