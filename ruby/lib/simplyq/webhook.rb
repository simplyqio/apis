# frozen_string_literal: true

require "openssl"
require "base64"

module Simplyq
  module Webhook
    DEFAULT_TOLERANCE = 300
    TIMESTAMP_HEADER = "x-simplyq-timestamp"
    SIGNATURE_HEADER = "x-simplyq-signature"

    # Verify signature of webhook request
    #
    # @param payload_body [String] raw payload body
    # @param signatures [String] request signature header
    # @param timestamp [String] request timestamp header
    # @param secret [String] your endpoint secret
    # @param tolerance [Integer] duration before signature expires
    #   (default: 300 seconds) replay attack protection
    # @raise [SignatureVerificationError] if signature verification fails
    #
    # @return [Boolean] true if signature verification succeeds
    def self.verify_signature(payload_body, signatures:, timestamp:, secret:, tolerance: DEFAULT_TOLERANCE)
      Signature.verify_header(payload_body, signatures, timestamp, secret, tolerance: tolerance)
    end

    # Decerialize and verify signature of payload into an InboundEvent
    #
    # @param payload_body [String] raw payload body
    # @param signatures [String] request signature header
    # @param timestamp [String] request timestamp header
    # @param secret [String] your endpoint secret
    # @param tolerance [Integer] duration before signature expires
    #   (default: 300 seconds) replay attack protection
    # @raise [SignatureVerificationError] if signature verification fails
    # @raise [JSON::ParserError] if payload_body is not valid JSON
    #
    # @return [Model::InboundEvent]
    def self.construct_event(payload_body, signatures:, timestamp:, secret:, tolerance: DEFAULT_TOLERANCE)
      Signature.verify_header(payload_body, signatures, timestamp, secret, tolerance: tolerance)

      Model::InboundEvent.from_hash(JSON.parse(payload_body, symbolize_names: true))
    end

    module Signature
      def self.calculate_signature(timestamp, payload, secret)
        raise ArgumentError, "timestamp should be an instance of Time" unless timestamp.is_a?(Time)
        raise ArgumentError, "payload should be a string" unless payload.is_a?(String)
        raise ArgumentError, "secret should be a string" unless secret.is_a?(String)

        sig = OpenSSL::HMAC.digest("SHA256", secret, "#{timestamp.to_i}#{payload}")
        Base64.strict_encode64(sig)
      end

      def self.verify_header(payload, signatures_header, timestamp_header, secret, tolerance: nil)
        timestamp, signatures = parse_timestampt_and_sigs(signatures_header, timestamp_header)

        expected_sig = calculate_signature(timestamp, payload, secret)
        unless signatures.any? { |sig| secure_compare(sig, expected_sig) }
          header = { TIMESTAMP_HEADER => timestamp_header, SIGNATURE_HEADER => signatures_header }
          raise Simplyq::SignatureVerificationError.new(
            "No signatures found matching the expected signature for payload",
            http_headers: header, http_body: payload
          )
        end

        if tolerance && timestamp < Time.now - tolerance
          header = { TIMESTAMP_HEADER => timestamp_header, SIGNATURE_HEADER => signatures_header }
          raise SignatureVerificationError.new(
            "Timestamp outside the tolerance zone (#{timestamp.to_i})",
            http_headers: header, http_body: payload
          )
        end

        true
      end

      def self.parse_timestampt_and_sigs(signatures_header, timestamp_header)
        timestamp = Integer(timestamp_header)

        signatures = signatures_header.split(",").map(&:strip)
        raise Simplyq::SignatureVerificationError.new("No signatures found", http_headers: header) if signatures.empty?

        [Time.at(timestamp), signatures]
      end
      private_class_method :parse_timestampt_and_sigs

      # Constant time string comparison to prevent timing attacks
      # Code borrowed from ActiveSupport
      def self.secure_compare(str_a, str_b)
        return false unless str_a.bytesize == str_b.bytesize

        l = str_a.unpack "C#{str_a.bytesize}"

        res = 0
        str_b.each_byte { |byte| res |= byte ^ l.shift }
        res.zero?
      end
      private_class_method :secure_compare
    end
  end
end
