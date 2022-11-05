# frozen_string_literal: true

module Simplyq
  module Model
    class InboundEvent
      attr_accessor :data

      def initialize(data)
        self.data = data
      end

      def self.from_hash(hash)
        return if hash.nil?

        new(hash)
      end

      def ==(other)
        return false unless other.is_a?(InboundEvent)

        data == other.data
      end

      def to_h
        data
      end

      def [](key)
        data[key]
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
