# frozen_string_literal: true

require "forwardable"

module Simplyq
  module Model
    class List
      extend Forwardable
      include Enumerable

      attr_accessor :data
      attr_accessor :has_more

      attr_accessor :data_type
      attr_accessor :api_method
      attr_accessor :list_args
      attr_accessor :filters
      attr_accessor :api

      def initialize(data_type, attributes = {}, api_method:, api:, filters: {}, list_args: [])
        self.data = if attributes.key?(:data)
                      attributes[:data].map do |item|
                        if data_type == Hash
                          item
                        else
                          data_type.from_hash(item)
                        end
                      end
                    else
                      []
                    end

        self.has_more = attributes[:has_more]

        self.data_type = data_type

        self.api_method = api_method

        self.filters = filters

        self.list_args = list_args

        self.api = api
      end

      def_delegators :data, :size, :length, :count, :empty?,
                     :first, :last, :each_with_index, :each_with_object,
                     :reduce, :inject, :find, :find_index, :index, :rindex

      def [](key)
        if key.is_a?(Integer)
          data[key]
        else
          instance_variable_get(:"@#{key}")
        end
      end

      # Iterates through each resource in the page represented by the current
      # `List`.
      #
      # Note that this method will not attempt to fetch the next page when it
      # reaches the end of the current page.
      def each(&blk)
        data.each(&blk)
      end

      # Iterates through each resource in the page represented by the current
      # `List`.
      #
      # Note that this method will not attempt to fetch the next page when it
      # reaches the end of the current page.
      def map(&blk)
        data.map(&blk)
      end

      def next_page
        return nil unless has_more || !empty?

        query_params = filters.dup.tap { |h| h.delete(:ending_before) }
        query_params[:start_after] = last.uid
        api.send(api_method, *list_args, query_params)
      end

      def prev_page
        return nil if empty?

        query_params = filters.dup.tap { |h| h.delete(:start_after) }
        query_params[:ending_before] = first.uid
        api.send(api_method, *list_args, query_params)
      end

      def to_h
        {
          data: data.map(&:to_h),
          has_more: has_more
        }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      # Serializes the object from a hash
      #
      # @param hash [Hash] Hash with the object data
      # @return [Simplyq::Model::List]
      def self.from_hash(hash, data_type, api:, filters: {})
        return if hash.nil?

        new(data_type, hash, api: api, filters: filters)
      end

      def ==(other)
        return false unless other.is_a?(List)

        data == other.data && has_more == other.has_more
      end
    end
  end
end
