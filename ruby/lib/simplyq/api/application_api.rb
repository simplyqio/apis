# frozen_string_literal: true

module Simplyq
  module API
    class ApplicationAPI
      attr_reader :client

      API_PATH = "/v1/application"
      API_PARAM_PATH = "/v1/application/{app_id}"

      # Initializes a new API object.
      #
      # @param client [Simplyq::Client] the client object that will be used to
      #   make HTTP requests.
      def initialize(client)
        @client = client
      end

      def retrieve(application_id)
        path = API_PARAM_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:get, path)
        decerialize(data)
      end

      def list(params = {})
        data, status, headers = client.call_api(:get, API_PATH, { query_params: params })
        decerialize_list(data, params: params)
      end

      def create(application)
        data, status, headers = client.call_api(:post, API_PATH, build_model(application).to_h)
        decerialize(data)
      end

      def update(application_id, attributes)
        path = API_PARAM_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:put, path, attributes)
        decerialize(data)
      end

      def delete(application_id)
        path = API_PARAM_PATH.gsub("{app_id}", application_id)

        data, status, headers = client.call_api(:delete, path)
        status == 204
      end

      def build_model(data)
        return data if data.is_a?(Simplyq::Model::Application)
        raise ArgumentError, "Invalid data must be a Simplyq::Model::Application or Hash" unless data.is_a?(Hash)

        Simplyq::Model::Application.from_hash(data)
      end

      def decerialize(json_data)
        data = body_to_json(json_data)

        Simplyq::Model::Application.from_hash(data)
      end

      def decerialize_list(json_data, params: {})
        data = body_to_json(json_data)

        Simplyq::Model::List.from_hash(data, Simplyq::Model::Application, filters: params, api: self)
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
