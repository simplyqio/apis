# frozen_string_literal: true

module Simplyq
  module Model
    class DeliveryAttempt
      attr_accessor :id

      attr_accessor :event_id

      attr_accessor :endpoint_id

      # The response of the endpoint when a delivery attempt was made or null if not yet attempted.
      attr_accessor :response

      # The response code of the endpoint when the event delivery was attempted.
      attr_accessor :response_status_code

      # The delivery status of the event to the endpoint
      attr_accessor :status

      # The tigger of the delivery attempt
      attr_accessor :trigger_type

      # This is the timestamp of when the delivery attempt was made to the endpoint. In case it has not yet been attempted and the status of the delivery attempt is **pending**, then the value of the timestamp will be **null**.
      attr_accessor :attempted_at

      def initialize(attributes = {})
        self.id = attributes[:id] if attributes.key?(:id)

        self.event_id = attributes[:event_id] if attributes.key?(:event_id)

        self.endpoint_id = attributes[:endpoint_id] if attributes.key?(:endpoint_id)

        self.response = attributes[:response] if attributes.key?(:response)

        self.response_status_code = attributes[:response_status_code] if attributes.key?(:response_status_code)

        self.status = attributes[:status] if attributes.key?(:status)

        self.trigger_type = attributes[:trigger_type] if attributes.key?(:trigger_type)

        self.attempted_at = attributes[:attempted_at] if attributes.key?(:attempted_at)
      end

      # The model identifier attribute used in list operations
      #
      # @return [Symbol]
      def self.identifier
        :id
      end

      # Serializes the object from a hash
      #
      # @param hash [Hash] Hash with the object data
      # @return [Simplyq::Model::Endpoint]
      def self.from_hash(hash)
        return if hash.nil?

        new(hash)
      end

      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def validation_errors
        []
      end

      # Check if the model is valid
      # @return true if valid, false otherwise
      def valid?
        validation_errors.empty?
      end

      def [](key)
        instance_variable_get(:"@#{key}")
      end

      def ==(other)
        return false if other.nil?

        self.class == other.class &&
          id == other.id &&
          event_id == other.event_id &&
          endpoint_id == other.endpoint_id &&
          response == other.response &&
          response_status_code == other.response_status_code &&
          status == other.status &&
          trigger_type == other.trigger_type &&
          attempted_at == other.attempted_at
      end

      def to_h
        {
          id: id,
          event_id: event_id,
          endpoint_id: endpoint_id,
          response: response,
          response_status_code: response_status_code,
          status: status,
          trigger_type: trigger_type,
          attempted_at: attempted_at
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
