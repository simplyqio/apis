# frozen_string_literal: true

module Simplyq
  module Model
    class Event
      attr_accessor :uid

      attr_accessor :event_type

      attr_accessor :topics

      attr_accessor :payload

      attr_accessor :retention_period

      attr_accessor :created_at

      def initialize(attributes = {})
        self.uid = attributes[:uid] if attributes.key?(:uid)

        self.event_type = attributes[:event_type] if attributes.key?(:event_type)

        self.topics = attributes[:topics] if attributes.key?(:topics)

        self.payload = attributes[:payload] if attributes.key?(:payload)

        self.retention_period = attributes[:retention_period] if attributes.key?(:retention_period)

        self.created_at = attributes[:created_at] if attributes.key?(:created_at)
      end

      # The model identifier attribute used in list operations
      #
      # @return [Symbol]
      def self.identifier
        :uid
      end

      # Serializes the object from a hash
      #
      # @param hash [Hash] Hash with the object data
      # @return [Simplyq::Model::Event]
      def self.from_hash(hash)
        return if hash.nil?

        new(hash)
      end

      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def validation_errors
        invalid_properties = []
        if !@uid.nil? && @uid.to_s.length > 255
          invalid_properties.push('invalid value for "uid", the character length must be smaller than or equal to 255.')
        end

        if !@uid.nil? && @uid.to_s.empty?
          invalid_properties.push('invalid value for "uid", the character length must be great than or equal to 1.')
        end

        pattern = Regexp.new(/^[a-zA-Z0-9\-_.]+$/)
        if !@uid.nil? && @uid !~ pattern
          invalid_properties.push("invalid value for \"uid\", must conform to the pattern #{pattern}.")
        end

        if !@event_type.nil? && @event_type.to_s.length > 255
          invalid_properties.push('invalid value for "event_type", the character length must be smaller than or equal to 255.')
        end

        if !@event_type.nil? && @event_type.to_s.empty?
          invalid_properties.push('invalid value for "event_type", the character length must be great than or equal to 1.')
        end

        pattern = Regexp.new(/^[a-zA-Z0-9\-_.]+$/)
        if !@event_type.nil? && @event_type !~ pattern
          invalid_properties.push("invalid value for \"event_type\", must conform to the pattern #{pattern}.")
        end

        if !@retention_period.nil? && @retention_period > 90
          invalid_properties.push('invalid value for "retention_period", must be smaller than or equal to 90.')
        end

        if !@retention_period.nil? && @retention_period < 5
          invalid_properties.push('invalid value for "retention_period", must be greater than or equal to 5.')
        end

        invalid_properties
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
        return false unless other.is_a?(Event)

        uid == other.uid &&
          event_type == other.event_type &&
          topics == other.topics &&
          payload == other.payload &&
          retention_period == other.retention_period &&
          created_at == other.created_at
      end

      def to_h
        {
          uid: uid,
          event_type: event_type,
          topics: topics,
          payload: payload,
          retention_period: retention_period,
          created_at: created_at
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
