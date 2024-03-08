require "openssl"
require "digest"

module Revolut
  class WebhookEvent < Resource
    shallow # do not allow any resource operations on this resource

    # Constructs a new instance of the WebhookEvent class from a request object and a signing secret.
    #
    # @param request [ActionDispatch::Request] The request object containing the webhook event data.
    # @param signing_secret [String] The signing secret used to verify the signature of the webhook event.
    # @return [WebhookEvent] A new instance of the WebhookEvent class.
    # @raise [Revolut::SignatureVerificationError] If the signature verification fails.
    def self.construct_from(request, signing_secret)
      json = request.body.read
      timestamp = request.headers["Revolut-Request-Timestamp"]
      header_signatures = request.headers["Revolut-Signature"].split(",")
      payload_to_sign = "v1.#{timestamp}.#{json}"
      digest = OpenSSL::Digest.new("sha256")
      signature_digest = "v1=" + OpenSSL::HMAC.hexdigest(digest, signing_secret, payload_to_sign)

      if header_signatures.include? signature_digest
        new(JSON.parse(json))
      else
        raise Revolut::SignatureVerificationError, "Signature verification failed"
      end
    end
  end
end
