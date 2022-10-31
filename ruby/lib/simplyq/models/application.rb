# frozen_string_literal: true

module Simplyq
  module Model
    class Application
      # Unique identifier for the application
      attr_accessor :uid

      attr_accessor :name

      attr_accessor :rate_limit

      attr_accessor :created_at

      attr_accessor :updated_at

      attr_accessor :retry_strategy

      def initialize(attributes = {})
        self.uid = attributes[:uid] if attributes.key?(:uid)

        self.name = attributes[:name] if attributes.key?(:name)

        self.rate_limit = attributes[:rate_limit] if attributes.key?(:rate_limit)

        self.created_at = attributes[:created_at] if attributes.key?(:created_at)

        self.updated_at = attributes[:updated_at] if attributes.key?(:updated_at)

        self.retry_strategy = if attributes.key?(:retry_strategy)
                                RetryStrategy.from_hash(attributes[:retry_strategy])
                              else
                                RetryStrategy.new
                              end
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
      # @return [Simplyq::Model::Application]
      def self.from_hash(hash)
        return if hash.nil?

        new(hash)
      end

      # Show invalid properties with the reasons. Usually used together with valid?
      # @return Array for valid properties with the reasons
      def validation_errors
        invalid_properties = []
        invalid_properties.push('invalid value for "uid", uid cannot be nil.') if @uid.nil?

        if @uid.to_s.length > 255
          invalid_properties.push('invalid value for "uid", the character length must be smaller than or equal to 255.')
        end

        if @uid.to_s.empty?
          invalid_properties.push('invalid value for "uid", the character length must be great than or equal to 1.')
        end

        pattern = Regexp.new(/^[a-zA-Z0-9\-_.]+$/)
        invalid_properties.push("invalid value for \"uid\", must conform to the pattern #{pattern}.") if @uid !~ pattern

        invalid_properties.push('invalid value for "name", name cannot be nil.') if @name.nil?

        unless @retry_strategy.valid?
          invalid_properties.concat(@retry_strategy.validation_errors.map { |x| "retry_strategy.#{x}" })
        end

        invalid_properties
      end

      # Check to see if all the properties in the model are valid
      def valid?
        validation_errors.empty? && retry_strategy.valid?
      end

      def [](key)
        instance_variable_get(:"@#{key}")
      end

      def ==(other)
        return false unless other.is_a?(Application)

        uid == other.uid &&
          name == other.name &&
          rate_limit == other.rate_limit &&
          created_at == other.created_at &&
          updated_at == other.updated_at &&
          retry_strategy == other.retry_strategy
      end

      def to_h
        {
          uid: uid,
          name: name,
          rate_limit: rate_limit,
          retry_strategy: retry_strategy.to_h,
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      class RetryStrategy
        # The retry strategy type identifies what algorithm will be used

        SUPPORTED_TYPES = [
          DEFAULT_TYPE = "base_exponential_backoff_with_deadline",
          "exponential_backoff",
          "exponential_backoff_with_deadline",
          "fixed_wait",
          "fixed_wait_with_deadline"
        ].freeze

        attr_accessor :type

        attr_accessor :max_retries

        attr_accessor :retry_delay

        attr_accessor :deadline

        def initialize(attributes = {})
          self.type = DEFAULT_TYPE
          self.type = attributes[:type] if attributes.key?(:type)

          self.max_retries = attributes[:max_retries] if attributes.key?(:max_retries)

          self.retry_delay = attributes[:retry_delay] if attributes.key?(:retry_delay)

          self.deadline = attributes[:deadline] if attributes.key?(:deadline)
        end

        def self.from_hash(hash)
          return if hash.nil?

          new(hash)
        end

        # Show invalid properties with the reasons. Usually used together with valid?
        # @return Array for valid properties with the reasons
        def validation_errors
          invalid_properties = []

          unless SUPPORTED_TYPES.include?(@type)
            invalid_properties.push("invalid value for \"type\", must be one of #{SUPPORTED_TYPES.join(", ")}.")
          end

          invalid_properties
        end

        # Check to see if all the properties in the model are valid
        def valid?
          validation_errors.empty?
        end

        def [](key)
          instance_variable_get(:"@#{key}")
        end

        def ==(other)
          return false unless other.is_a?(RetryStrategy)

          type == other.type &&
            max_retries == other.max_retries &&
            retry_delay == other.retry_delay &&
            deadline == other.deadline
        end

        def to_h
          {
            type: type,
            max_retries: max_retries,
            retry_delay: retry_delay,
            deadline: deadline
          }
        end

        def to_json(*args)
          to_h.to_json(*args)
        end
      end
    end
  end
end
