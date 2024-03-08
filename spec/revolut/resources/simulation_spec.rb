RSpec.describe Revolut::Simulation do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "#resources_name" do
    expect(described_class.resources_name).to eq "sandbox"
  end

  it "is shallow" do
    expect(described_class.send(:only)).to eq [:shallow]
  end

  describe "#update_transaction" do
    it "updates a transaction when the environment is sandbox" do
      Revolut.config.environment = :sandbox

      allow(described_class.http_client).to receive(:post).with("/sandbox/transactions/1/complete").and_return(
        OpenStruct.new(
          body: {
            "id" => "c6db947e-e9ce-41c2-b445-02e6eb741d21",
            "state" => "completed"
          }
        )
      )

      transaction = described_class.update_transaction(1, action: :complete)

      expect(transaction).to be_a(Revolut::Transaction)
      expect(transaction).to have_attributes(
        id: "c6db947e-e9ce-41c2-b445-02e6eb741d21",
        state: "completed"
      )
    end

    it "raises an error if the environment is production" do
      Revolut.config.environment = :production

      expect { described_class.update_transaction(1, action: :complete) }.to raise_error(Revolut::UnsupportedOperationError, "#update_transaction is meant to be run only in sandbox environments")
    end

    it "raises an error if the action is unsupported" do
      Revolut.config.environment = :sandbox

      expect { described_class.update_transaction(1, action: :unsupported) }.to raise_error(Revolut::UnsupportedOperationError, "The action `unsupported` is not supported")
    end
  end

  describe "#top_up_account" do
    let(:data) do
      {
        account_id: 1,
        amount: 100,
        currency: "USD",
        reference: "Test Top-up",
        state: "completed"
      }
    end

    it "tops up an account" do
      Revolut.config.environment = :sandbox

      allow(described_class.http_client).to receive(:post).with("/sandbox/topup", data:).and_return(
        OpenStruct.new(body: {id: "330953b8-b089-4cfd-9f03-e88173d64248", state: "completed"})
      )

      transaction = described_class.top_up_account(1, **data.except(:account_id))

      expect(transaction).to be_a(Revolut::Transaction)
      expect(transaction).to have_attributes(
        id: "330953b8-b089-4cfd-9f03-e88173d64248",
        state: "completed"
      )
    end

    it "raises an error if the environment is production" do
      Revolut.config.environment = :production

      expect { described_class.top_up_account(1, **data.except(:account_id)) }.to raise_error(Revolut::UnsupportedOperationError, "#top_up_account is meant to be run only in sandbox environments")
    end
  end
end
