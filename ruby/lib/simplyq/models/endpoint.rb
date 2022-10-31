# frozen_string_literal: true

module Simplyq
  module Model
    class Endpoint
      # Unique identifier of the endpoint inside the application.
      attr_accessor :uid

      attr_accessor :url

      attr_accessor :version

      attr_accessor :description

      attr_accessor :filter_types

      attr_accessor :topics

      attr_accessor :active

      attr_accessor :rate_limit

      attr_accessor :headers

      attr_accessor :secret

      attr_accessor :created_at

      attr_accessor :updated_at

      def initialize(attributes = {})
        self.uid = attributes[:uid] if attributes.key?(:uid)

        self.url = attributes[:url] if attributes.key?(:url)

        self.version = attributes[:version] if attributes.key?(:version)

        self.description = attributes[:description] if attributes.key?(:description)

        self.filter_types = attributes[:filter_types] if attributes.key?(:filter_types)

        self.topics = attributes[:topics] if attributes.key?(:topics)

        self.active = attributes[:active] if attributes.key?(:active)

        self.rate_limit = attributes[:rate_limit] if attributes.key?(:rate_limit)

        self.headers = if attributes.key?(:headers)
                         Headers.from_hash(attributes[:headers])
                       else
                         Headers.new
                       end

        self.secret = attributes[:secret] if attributes.key?(:secret)

        self.created_at = attributes[:created_at] if attributes.key?(:created_at)

        self.updated_at = attributes[:updated_at] if attributes.key?(:updated_at)
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
      # @return [Simplyq::Model::Endpoint]
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

        if !@uid.nil? && @uid.to_s.length < 1
          invalid_properties.push('invalid value for "uid", the character length must be great than or equal to 1.')
        end

        pattern = Regexp.new(/^[a-zA-Z0-9\-_.]+$/)
        if !@uid.nil? && @uid !~ pattern
          invalid_properties.push("invalid value for \"uid\", must conform to the pattern #{pattern}.")
        end

        invalid_properties.push('invalid value for "url", url cannot be nil.') if @url.nil?

        invalid_properties.push('invalid value for "version", version cannot be nil.') if @version.nil?

        if !@topics.nil? && @topics.length > 5
          invalid_properties.push('invalid value for "topics", number of items must be less than or equal to 5.')
        end

        if !@topics.nil? && @topics.length < 1
          invalid_properties.push('invalid value for "topics", number of items must be greater than or equal to 1.')
        end

        if !@rate_limit.nil? && @rate_limit < 1
          invalid_properties.push('invalid value for "rate_limit", must be greater than or equal to 1.')
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
        return false if other.nil?

        self.class == other.class &&
          uid == other.uid &&
          url == other.url &&
          version == other.version &&
          description == other.description &&
          filter_types == other.filter_types &&
          topics == other.topics &&
          active == other.active &&
          rate_limit == other.rate_limit &&
          headers == other.headers &&
          secret == other.secret &&
          created_at == other.created_at &&
          updated_at == other.updated_at
      end

      def to_h
        {
          uid: uid,
          url: url,
          version: version,
          description: description,
          filter_types: filter_types,
          topics: topics,
          active: active,
          rate_limit: rate_limit,
          headers: headers.to_h,
          secret: secret,
          created_at: created_at,
          updated_at: updated_at
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      class Headers
        attr_accessor :headers

        attr_accessor :sensitive

        def initialize(attributes = {})
          self.headers = attributes[:headers] if attributes.key?(:headers)

          self.sensitive = attributes[:sensitive] if attributes.key?(:sensitive)
        end

        def has_sensitive?
          !sensitive.nil? && !sensitive.empty?
        end

        # Serializes the object from a hash
        #
        # @param hash [Hash] Hash with the object data
        # @return [Simplyq::Model::Endpoint::Headers]
        def self.from_hash(hash)
          return if hash.nil?

          new(hash)
        end

        # Show invalid properties with the reasons. Usually used together with valid?
        #
        # TODO: Add header object validation
        #
        # @return Array for valid properties with the reasons
        def validation_errors
          []
        end

        def valid?
          validation_errors.empty?
        end

        def [](key)
          instance_variable_get(:"@#{key}")
        end

        def ==(other)
          return false if other.nil?

          self.class == other.class &&
            headers == other.headers &&
            sensitive == other.sensitive
        end

        def to_h
          {
            headers: headers,
            sensitive: sensitive
          }
        end

        def to_json(*args)
          to_h.to_json(*args)
        end
      end
    end
  end
end
