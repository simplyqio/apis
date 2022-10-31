# frozen_string_literal: true

require "faraday"

module Simplyq
  class Client
    HEADER_AUTHORIZATION = "Authorization"

    USER_AGENT = "simplyq-ruby/#{Simplyq::VERSION}"

    attr_reader :config

    # Initialize client to connect to SimplyQ API
    #
    # @param config_options [Simplyq::Configuration|Hash] a configuration object or a hash of configuration options
    def initialize(config_options = {})
      @config = case config_options
                when Hash
                  Simplyq::Configuration.setup do |config|
                    config_options.each do |key, value|
                      config.send("#{key}=", value)
                    end
                  end
                when Simplyq::Configuration
                  config_options
                else
                  raise ArgumentError, "Invalid configuration options #{config_options}"
                end
      @default_headers = {
        "Content-Type" => "application/json",
        "User-Agent" => USER_AGENT
      }
    end

    def check_api_key!
      raise AuthenticationError, "No API key provided." unless config.api_key

      raise AuthenticationError, "Invalid API key as it includes spaces" if config.api_key =~ /\s/
    end

    ERROR_MESSAGE_CONNECTION =
      "Unexpected error communicating when trying to connect to " \
      "SimplyQ (%s). You may be seeing this message because your DNS is not " \
      "working or you don't have an internet connection.  To check, try " \
      "running `host api.simplyq.com` from the command line."
    ERROR_MESSAGE_SSL =
      "Could not establish a secure connection to SimplyQ (%s), you " \
      "may need to upgrade your OpenSSL version. To check, try running " \
      "`openssl s_client -connect api.simplyq.com:443` from the command " \
      "line."

    ERROR_MESSAGE_TIMEOUT_SUFFIX =
      "Please check your internet connection and try again. " \
      "If this problem persists, you should check SimplyQ's service " \
      "status at https://simplyq.statuspage.io, or let us know at " \
      "support@simplyq.io."

    ERROR_MESSAGE_TIMEOUT_CONNECT =
      "Timed out connecting to SimplyQ (%s). #{ERROR_MESSAGE_TIMEOUT_SUFFIX}"

    ERROR_MESSAGE_TIMEOUT_READ =
      "Timed out communicating with SimplyQ (%s). #{ERROR_MESSAGE_TIMEOUT_SUFFIX}"

    NETWORK_ERROR_MESSAGES_MAP = {
      EOFError => ERROR_MESSAGE_CONNECTION,
      Errno::ECONNREFUSED => ERROR_MESSAGE_CONNECTION,
      Errno::ECONNRESET => ERROR_MESSAGE_CONNECTION,
      Errno::EHOSTUNREACH => ERROR_MESSAGE_CONNECTION,
      Errno::ETIMEDOUT => ERROR_MESSAGE_TIMEOUT_CONNECT,
      SocketError => ERROR_MESSAGE_CONNECTION,

      Net::OpenTimeout => ERROR_MESSAGE_TIMEOUT_CONNECT,
      Net::ReadTimeout => ERROR_MESSAGE_TIMEOUT_READ,

      Faraday::TimeoutError => ERROR_MESSAGE_TIMEOUT_READ,
      Faraday::ConnectionFailed => ERROR_MESSAGE_CONNECTION,

      OpenSSL::SSL::SSLError => ERROR_MESSAGE_SSL,
      Faraday::SSLError => ERROR_MESSAGE_SSL
    }.freeze
    private_constant :NETWORK_ERROR_MESSAGES_MAP

    # Call an API with given options.
    #
    # @return [Array<(Object, Integer, Hash)>] an array of 3 elements:
    #   the data deserialized from response body (could be nil), response status code and response headers.
    def call_api(http_method, path, opts = {})
      check_api_key!

      begin
        response = connection.public_send(http_method.to_sym.downcase) do |req|
          build_request(http_method, path, req, opts)
        end

        config.logger.debug "HTTP response body ~BEGIN~\n#{response.body}\n~END~\n" if config.debugging

        unless response.success?
          if response.status.zero?
            # Errors from libcurl will be made visible here
            raise ApiError.new(response.reason_phrase, http_status: 0)
          else
            raise specific_http_error(response, get_http_error_data(response).merge(params: opts[:query_params]))
          end
        end
      rescue *NETWORK_ERROR_MESSAGES_MAP.keys => e
        handle_network_error(e)
      end

      [response.body, response.status, response.headers]
    end

    def handle_network_error(error)
      errors, message = NETWORK_ERROR_MESSAGES_MAP.detect do |(e, _)|
        error.is_a?(e)
      end

      if errors.nil?
        message = "Unexpected error #{error.class.name} communicating " \
                  "with SimplyQ. Please let us know at support@simplyq.io."
      end

      message = message % config.base_url
      message += "\n\n(Network error: #{error.message})"

      raise APIConnectionError.new(message, http_status: 0, error: error)
    end

    def get_http_error_data(response)
      body = safe_json_parse_body(response)
      if body.is_a?(Hash)
        message = body["error"] || body["message"]

        message = "Invalid request" if message.nil? && body["errors"]

        return {
          message: message,
          errors: body["errors"],
          code: body["code"]
        }
      end

      { message: response.reason_phrase }
    end

    def safe_json_parse_body(response)
      return nil if response.body.nil?

      JSON.parse(response.body)
    rescue JSON::ParserError
      nil
    end

    def specific_http_error(resp, error_data = {})
      # The standard arguments that are passed to API exceptions
      opts = {
        http_body: resp.body,
        http_headers: resp.headers,
        http_status: resp.status,
        code: error_data[:code]
      }

      case resp.status
      when 400, 404, 422
        case error_data[:type]
        when "idempotency_error"
          IdempotencyError.new(error_data[:message], **opts)
        else
          InvalidRequestError.new(
            error_data[:message], error_data[:param],
            **opts.merge(errors: error_data[:errors])
          )
        end
      when 401
        AuthenticationError.new(error_data[:message] || resp.reason_phrase, **opts)
      when 402
        PaymentRequiredError.new(error_data[:message] || resp.reason_phrase, **opts)
      when 403
        PermissionError.new(error_data[:message] || resp.reason_phrase, **opts)
      when 429
        RateLimitError.new(error_data[:message] || resp.reason_phrase, **opts)
      else
        APIError.new(error_data[:message] || resp.reason_phrase, **opts)
      end
    end

    def build_request_url(path)
      # Add leading and trailing slashes to path
      path = "/#{path}".gsub(%r{/+}, "/")
      @config.base_url + path
    end

    # Builds the HTTP request
    #
    # @param [String] http_method HTTP method/verb (e.g. POST)
    # @param [String] path URL path (e.g. /account/new)
    # @option opts [Hash] :header_params Header parameters
    # @option opts [Hash] :query_params Query parameters
    # @option opts [Hash] :form_params Query parameters
    # @option opts [Object] :body HTTP body (JSON/XML)
    # @return [Faraday::Request] A Faraday Request
    def build_request(http_method, path, request, opts = {})
      url = build_request_url(path)
      http_method = http_method.to_sym.downcase

      header_params = @default_headers.merge(opts[:header_params] || {})
      query_params = opts[:query_params] || {}
      form_params = opts[:form_params] || {}

      header_params[HEADER_AUTHORIZATION] = config.auth_api_key

      if %i[post patch put delete].include?(http_method)
        req_body = build_request_body(header_params, form_params, opts[:body])
        config.logger.debug "HTTP request body param ~BEGIN~\n#{req_body}\n~END~\n" if config.debugging
      end
      request.headers = header_params
      request.body = req_body

      # Overload default options only if provided
      request.options.timeout = config.timeout if config.timeout

      request.url url
      request.params = query_params
      download_file(request) if opts[:return_type] == "File" || opts[:return_type] == "Binary"
      request
    end

    # Builds the HTTP request body
    #
    # @param [Hash] header_params Header parameters
    # @param [Hash] form_params Query parameters
    # @param [Object] body HTTP body (JSON/XML)
    # @return [String] HTTP body data in the form of string
    def build_request_body(header_params, form_params, body)
      # http form
      if header_params["Content-Type"] == "application/x-www-form-urlencoded"
        data = URI.encode_www_form(form_params)
      elsif header_params["Content-Type"] == "multipart/form-data"
        data = {}
        form_params.each do |key, value|
          data[key] = case value
                      when ::File, ::Tempfile
                        Faraday::FilePart.new(value.path, "application/octet-stream", value.path)
                      when ::Array, nil
                        # let Faraday handle Array and nil parameters
                        value
                      else
                        value.to_s
                      end
        end
      elsif body
        data = body.is_a?(String) ? body : body.to_json
      else
        data = nil
      end
      data
    end

    def connection
      @connection ||= build_connection
    end

    def build_connection
      Faraday.new(url: config.base_url, ssl: ssl_options, proxy: config.proxy) do |conn|
        basic_auth(conn)
        config.configure_middleware(conn)
        yield(conn) if block_given?
        conn.adapter(Faraday.default_adapter)
      end
    end

    def ssl_options
      {
        ca_file: config.ssl_ca_file,
        verify: config.ssl_verify,
        verify_mode: config.ssl_verify_mode,
        client_cert: config.ssl_client_cert,
        client_key: config.ssl_client_key
      }
    end

    def basic_auth(conn)
      if config.username && config.password
        if Gem::Version.new(Faraday::VERSION) >= Gem::Version.new("2.0")
          conn.request(:authorization, :basic, config.username, config.password)
        else
          conn.request(:basic_auth, config.username, config.password)
        end
      end
    end
  end
end
