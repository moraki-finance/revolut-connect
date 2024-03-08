module Revolut
  # Reference: https://developer.revolut.com/docs/business/counterparties
  class Simulation < Resource
    shallow

    def self.resources_name
      "sandbox"
    end

    # Updates a transaction in the sandbox environment.
    #
    # @param id [String] The ID of the transaction to update.
    # @param action [Symbol] The action to perform on the transaction.
    # @return [Revolut::Transaction] The updated transaction object.
    # @raise [Revolut::UnsupportedOperationError] If the method is called in a non-sandbox environment or if the action is not supported.
    def self.update_transaction(id, action:)
      raise Revolut::UnsupportedOperationError, "#update_transaction is meant to be run only in sandbox environments" unless Revolut.sandbox?
      raise Revolut::UnsupportedOperationError, "The action `#{action}` is not supported" unless %i[complete revert declined fail].include?(action)

      response = http_client.post("/#{resources_name}/transactions/#{id}/#{action}")

      Revolut::Transaction.new(response.body)
    end

    # Adds funds to the specified account in the sandbox environment.
    #
    # @param id [String] The ID of the account to top up.
    # @param data [Hash] Additional data for the top-up request.
    # @option data [Float] :amount The amount to top up the account by.
    # @option data [String] :currency The currency of the top-up amount.
    # @return [Revolut::Transaction] The transaction object representing the top-up.
    # @raise [Revolut::UnsupportedOperationError] If the method is called outside of the sandbox environment.
    def self.top_up_account(id, **data)
      raise Revolut::UnsupportedOperationError, "#top_up_account is meant to be run only in sandbox environments" unless Revolut.sandbox?

      response = http_client.post("/#{resources_name}/topup", data: data.merge(account_id: id))

      Revolut::Transaction.new(response.body)
    end
  end
end
