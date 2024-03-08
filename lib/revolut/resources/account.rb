module Revolut
  # Reference: https://developer.revolut.com/docs/business/counterparties
  class Account < Resource
    not_allowed_to :create, :update, :delete

    def self.resources_name
      "accounts"
    end

    # Retrieves the bank details for a specific account.
    #
    # @param id [String] The ID of the account.
    # @return [Array<Revolut::BankAccount>] An array of bank account objects.
    def self.bank_details(id)
      response = http_client.get("/#{resources_name}/#{id}/bank-details")

      response.body.map(&Revolut::BankAccount)
    end
  end
end
