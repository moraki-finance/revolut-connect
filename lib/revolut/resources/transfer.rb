require "forwardable"

module Revolut
  class Transfer < Resource
    only :create

    class << self
      extend Forwardable

      # Delegate list_reasons to the list method on TransferReason
      def_delegator :transfer_reason, :list, :list_reasons

      def resource_name
        "transfer"
      end

      def transfer_reason
        Revolut::TransferReason
      end
    end
  end
end
