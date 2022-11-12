# frozen_string_literal: true

RSpec.describe Simplyq::Webhook do
  let(:secret) { "enps_IKcXI8wR5EVoA/fKUIZTMtO60YHZ696d" }
  let(:signature) { "po8q9fly6+pqX6iX9Jjl8Cd93IpVAldwchxncT8dfBI=" }
  let(:headers) do
    {
      "x-simplyq-signature" => signature,
      "x-simplyq-timestamp" => timestamp
    }
  end
  let(:timestamp) { "1667537928" }
  let(:payload) do
    '{"message":"Hello World!"}'
  end

  describe "#verify_signature" do
    it "returns true when the signature is valid" do
      expect(described_class.verify_signature(payload, signatures: signature, timestamp: timestamp, secret: secret, tolerance: nil)).to be(true)
    end

    it "returns false when the signature is invalid" do
      expect { described_class.verify_signature("not it", signatures: signature, timestamp: timestamp, secret: secret, tolerance: nil) }
        .to raise_error(Simplyq::SignatureVerificationError) do |error|
          expect(error.message).to eq("No signatures found matching the expected signature for payload")
        end
    end

    context "when the timestamp is too old" do
      it "raises an error" do
        expect { described_class.verify_signature(payload, signatures: signature, timestamp: timestamp, secret: secret, tolerance: 300) }
          .to raise_error(Simplyq::SignatureVerificationError) do |error|
            expect(error.message).to eq("Timestamp outside the tolerance zone (1667537928)")
          end
      end
    end

    context "when data is invalid" do
      it "raises when the payload is not a string" do
        expect { described_class.verify_signature({ message: "Hello World!" }, signatures: signature, timestamp: timestamp, secret: secret, tolerance: nil) }
          .to raise_error(ArgumentError, "payload should be a string")
      end

      it "raises when the secret is not a string" do
        expect { described_class.verify_signature(payload, signatures: signature, timestamp: timestamp, secret: 123, tolerance: nil) }
          .to raise_error(ArgumentError, "secret should be a string")
      end
    end
  end

  describe "#construct_event" do
    it "returns an InboundEvent" do
      event = described_class.construct_event(payload, signatures: signature, timestamp: timestamp, secret: secret, tolerance: nil)
      expect(event).to be_a(Simplyq::Model::InboundEvent)
      expect(event[:message]).to eq("Hello World!")
    end

    it "raises when the payload is not valid JSON" do
      payload = "not json"
      headers = generate_headers_for(payload, secret)
      signature = headers[Simplyq::Webhook::SIGNATURE_HEADER]
      timestamp = headers[Simplyq::Webhook::TIMESTAMP_HEADER]

      expect { described_class.construct_event(payload, signatures: signature, timestamp: timestamp, secret: secret) }
        .to raise_error(JSON::ParserError)
    end
  end
end
