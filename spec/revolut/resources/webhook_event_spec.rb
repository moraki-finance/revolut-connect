RSpec.describe Revolut::WebhookEvent do
  it "inherits from Resource" do
    expect(described_class).to be < Revolut::Resource
  end

  it "is shallow" do
    expect(described_class.send(:only)).to eq [:shallow]
  end

  describe "#construct_from" do
    subject { described_class.construct_from(request, wh_secret) }

    context "when the signature is valid" do
      let(:request) do
        # Simulate an ActionDispatch::Request.
        # Not in the mood today to include Rails in the gem as a dependency.
        OpenStruct.new(
          body: StringIO.new('{"data":{"id":"645a7696-22f3-aa47-9c74-cbae0449cc46","new_state":"completed","old_state":"pending","request_id":"app_charges-9f5d5eb3-1e06-46c5-b1c0-3914763e0bcb"},"event":"TransactionStateChanged","timestamp":"2023-05-09T16:36:38.028960Z"}'),
          headers: {
            "Revolut-Request-Timestamp" => "1683650202360",
            "Revolut-Signature" => "v1=bca326fb378d0da7f7c490ad584a8106bab9723d8d9cdd0d50b4c5b3be3837c0"
          }
        )
      end
      let(:wh_secret) { "wsk_r59a4HfWVAKycbCaNO1RvgCJec02gRd8" }

      it "returns a WebhookEvent with the correct data" do
        expect(subject).to be_a Revolut::WebhookEvent

        expect(subject).to have_attributes(
          event: "TransactionStateChanged",
          timestamp: "2023-05-09T16:36:38.028960Z"
        )

        expect(subject.data).to have_attributes(
          id: "645a7696-22f3-aa47-9c74-cbae0449cc46",
          new_state: "completed",
          old_state: "pending",
          request_id: "app_charges-9f5d5eb3-1e06-46c5-b1c0-3914763e0bcb"
        )
      end
    end

    context "when the signature is invalid" do
      let(:request) do
        # Simulate an ActionDispatch::Request
        # Not in the mood today to include Rails in the gem as a dependency.
        OpenStruct.new(
          body: StringIO.new('{"data":{"id":"a-different-id","new_state":"completed","old_state":"pending","request_id":"app_charges-9f5d5eb3-1e06-46c5-b1c0-3914763e0bcb"},"event":"TransactionStateChanged","timestamp":"2023-05-09T16:36:38.028960Z"}'),
          headers: {
            "Revolut-Request-Timestamp" => "1683650202360",
            "Revolut-Signature" => "v1=bca326fb378d0da7f7c490ad584a8106bab9723d8d9cdd0d50b4c5b3be3837c0"
          }
        )
      end
      let(:wh_secret) { "wsk_r59a4HfWVAKycbCaNO1RvgCJec02gRd8" }

      it "raises a SignatureVerificationError" do
        expect { subject }.to raise_error(Revolut::SignatureVerificationError, "Signature verification failed")
      end
    end
  end
end
