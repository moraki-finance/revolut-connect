module Revolut
  # Reference: https://developer.revolut.com/docs/business/counterparties
  class Webhook < Resource
    class << self
      def resources_name
        "webhooks"
      end

      def http_client
        @http_client ||= Revolut::Client.new(api_version: "2.0")
      end

      def rotate_signing_secret(id, **data)
        response = http_client.post("/#{resources_name}/#{id}/rotate-signing-secret", data:)

        new(response.body)
      end

      def failed_events(id)
        response = http_client.get("/#{resources_name}/#{id}/failed-events")

        response.body.map(&Revolut::WebhookEvent)
      end
    end
  end
end
