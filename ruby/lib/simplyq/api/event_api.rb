# frozen_string_literal: true

require "date"
require "time"

module Simplyq
  module API
    class EventAPI
      attr_reader :client

      API_PATH = "/v1/application/{app_id}/event"
      API_RETRIEVE_PATH = "/v1/application/{app_id}/event/{event_id}"
      API_DELIVERY_ATTEMPTS_PATH = "/v1/application/{app_id}/event/{event_id}/delivery_attempt"

      # Initializes a new API object.
      #
      # @param client [Simplyq::Client] the client object that will be used to
      #   make HTTP requests.
      def initialize(client)
        @client = client
      end

      def retrieve(application_id, event_id)
        path = API_RETRIEVE_PATH.gsub("{app_id}", application_id).gsub("{event_id}", event_id)

        data, status, headers = client.call_api(:get, path)
        decerialize(data)
      end

      def list(application_id, params = {})
        path = API_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:get, path, { query_params: params })
        decerialize_list(data, params: params, list_args: [application_id])
      end

      def create(application_id, event)
        path = API_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:post, path, { body: build_model(event).to_h })
        decerialize(data)
      end

      def retrieve_delivery_attempts(application_id, event_id, params = {})
        path = API_DELIVERY_ATTEMPTS_PATH.gsub("{app_id}", application_id).gsub("{event_id}", event_id)

        data, status, headers = client.call_api(:get, path, { query_params: params })
        decerialize_delivery_attempts_list(data, params: params, list_args: [application_id, event_id])
      end

      private

      def build_model(data)
        return data if data.is_a?(Simplyq::Model::Event)
        raise ArgumentError, "Invalid data must be a Simplyq::Model::Event or Hash" unless data.is_a?(Hash)

        Simplyq::Model::Event.from_hash(data)
      end

      def decerialize(json_data)
        data = body_to_json(json_data)

        Simplyq::Model::Event.from_hash(data)
      end

      def decerialize_list(json_data, params: {}, list_args: [])
        data = body_to_json(json_data)

        Simplyq::Model::List.new(
          Simplyq::Model::Event, data,
          api_method: :list,
          list_args: list_args,
          filters: params, api: self
        )
      end

      def decerialize_delivery_attempts_list(json_data, params: {}, list_args: [])
        data = body_to_json(json_data)

        Simplyq::Model::List.new(
          Simplyq::Model::DeliveryAttempt, data,
          api_method: :retrieve_delivery_attempts,
          list_args: list_args,
          filters: params, api: self
        )
      end

      def body_to_json(body)
        return if body.nil?

        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        raise Simplyq::APIError.new("Invalid JSON in response body.", http_body: body)
      end
    end
  end
end
