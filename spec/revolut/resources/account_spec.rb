RSpec.describe Revolut::Account do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "does not allow some operations" do
    expect(described_class.send(:not_allowed_to)).to eq [:create, :update, :delete]
  end

  it "#resources_name" do
    expect(described_class.resources_name).to eq "accounts"
  end

  it "#resource_name" do
    expect(described_class.send(:resource_name)).to eq "accounts"
  end

  describe "#bank_details" do
    it "lists resources" do
      allow(Revolut::Client.instance).to receive(:get).with("/accounts/1/bank-details").and_return(
        OpenStruct.new(body: [{"id" => 1, "name" => "Test"}])
      )

      bank_accounts = described_class.bank_details(1)
      bank_account = bank_accounts.first

      expect(bank_account).to be_a(Revolut::BankAccount)
      expect(bank_account.id).to eq(1)
      expect(bank_account.name).to eq("Test")
    end
  end
end
