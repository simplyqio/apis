# frozen_string_literal: true

require "date"
require "time"

module Simplyq
  module API
    class EndpointAPI
      attr_reader :client

      API_PATH = "/v1/application/{app_id}/endpoint"
      API_PARAM_PATH = "/v1/application/{app_id}/endpoint/{endpoint_id}"
      API_RECOVER_PATH = "/v1/application/{app_id}/endpoint/{endpoint_id}/recover"
      API_SECRET_PATH = "/v1/application/{app_id}/endpoint/{endpoint_id}/secret"

      # Initializes a new API object.
      #
      # @param client [Simplyq::Client] the client object that will be used to
      #   make HTTP requests.
      def initialize(client)
        @client = client
      end

      def retrieve(application_id, endpoint_id)
        path = API_PARAM_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:get, path)
        decerialize(data)
      end

      def list(application_id, params = {})
        path = API_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:get, path, { query_params: params })
        decerialize_list(data, params: params)
      end

      def create(application_id, endpoint)
        path = API_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:post, path, { body: build_model(endpoint).to_h })
        decerialize(data)
      end

      def update(application_id, endpoint_id, endpoint)
        path = API_PARAM_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:put, path, { body: build_model(endpoint).to_h })
        decerialize(data)
      end

      def delete(application_id, endpoint_id)
        path = API_PARAM_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:delete, path)
        status == 204
      end

      def recover(application_id, endpoint_id, since:)
        path = API_RECOVER_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:post, path, { body: { since: _to_rfc3339(since) } })
        status == 202
      end

      def retrieve_secret(application_id, endpoint_id)
        path = API_SECRET_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:get, path)
        decerialize_secret(data)
      end

      def rotate_secret(application_id, endpoint_id, secret: nil)
        path = API_SECRET_PATH.gsub("{app_id}", application_id).gsub("{endpoint_id}", endpoint_id)

        data, status, headers = client.call_api(:post, path, { body: { key: secret } })
        status == 204
      end

      def build_model(data)
        return data if data.is_a?(Simplyq::Model::Endpoint)
        raise ArgumentError, "Invalid data must be a Simplyq::Model::Endpoint or Hash" unless data.is_a?(Hash)

        Simplyq::Model::Endpoint.from_hash(data)
      end

      def decerialize(json_data)
        data = body_to_json(json_data)

        Simplyq::Model::Endpoint.from_hash(data)
      end

      def decerialize_secret(json_data)
        data = body_to_json(json_data)

        data[:key]
      end

      def decerialize_list(json_data, params: {})
        data = body_to_json(json_data)

        Simplyq::Model::List.new(Simplyq::Model::Endpoint, data, filters: params, api: self)
      end

      def body_to_json(body)
        return if body.nil?

        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        raise Simplyq::APIError.new("Invalid JSON in response body.", http_body: body)
      end

      def _to_rfc3339(time)
        _to_utc(time).iso8601(0)
      end

      def _to_utc(time)
        unless time.is_a?(Time) || time.is_a?(String) || time.is_a?(DateTime)
          raise ArgumentError,
                "Invalid time must be a Time, DateTime, String"
        end

        if time.is_a?(Time)
          time.utc
        elsif time.is_a?(DateTime)
          time.to_time.utc
        else
          Time.parse(time).utc
        end
      end
    end
  end
end
