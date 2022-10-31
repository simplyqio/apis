# frozen_string_literal: true

require "logger"

module Simplyq
  class Configuration
    # Defines API keys used with API Key authentications.
    attr_accessor :api_key

    # Defines the api version
    attr_accessor :api_version

    # Defines the logger used for debugging.
    # Default to `Rails.logger` (when in Rails) or logging to STDOUT.
    #
    # @return [#debug]
    attr_accessor :logger

    # Defines the username used with HTTP basic authentication.
    #
    # @return [String]
    attr_accessor :username

    # Defines the password used with HTTP basic authentication.
    #
    # @return [String]
    attr_accessor :password

    # Set this to false to skip client side validation in the operation.
    # Default to true.
    # @return [true, false]
    attr_accessor :client_side_validation

    ### TLS/SSL setting
    # Set this to false to skip verifying SSL certificate when calling API from https server.
    # Default to true.
    #
    # @note Do NOT set it to false in production code, otherwise you would face multiple types of cryptographic attacks.
    #
    # @return [true, false]
    attr_accessor :ssl_verify

    ### TLS/SSL setting
    # Any `OpenSSL::SSL::` constant (see https://ruby-doc.org/stdlib-2.5.1/libdoc/openssl/rdoc/OpenSSL/SSL.html)
    #
    # @note Do NOT set it to false in production code, otherwise you would face multiple types of cryptographic attacks.
    #
    attr_accessor :ssl_verify_mode

    ### TLS/SSL setting
    # Set this to customize the certificate file to verify the peer.
    #
    # @return [String] the path to the certificate file
    attr_accessor :ssl_ca_file

    ### TLS/SSL setting
    # Client certificate file (for client certificate)
    attr_accessor :ssl_client_cert

    ### TLS/SSL setting
    # Client private key file (for client certificate)
    attr_accessor :ssl_client_key

    ### Proxy setting
    # HTTP Proxy settings
    attr_accessor :proxy

    attr_accessor :timeout

    attr_accessor :base_url

    attr_accessor :debugging

    attr_reader :open_timeout
    attr_reader :read_timeout
    attr_reader :write_timeout

    def self.setup
      new.tap do |instance|
        yield(instance) if block_given?
      end
    end

    def initialize
      @timeout = 30
      @open_timeout = 30
      @read_timeout = 80
      @write_timeout = 30

      @client_side_validation = true

      @base_url = "https://api.simplyq.io"
      @middlewares = Hash.new { |h, k| h[k] = [] }
      @logger = defined?(Rails) ? Rails.logger : Logger.new($stdout)

      yield(self) if block_given?
    end

    # The default Configuration object.
    def self.default
      Configuration.new
    end

    # Gets Basic Auth token string
    def basic_auth_token
      "Basic #{["#{username}:#{password}"].pack("m").delete("\r\n")}"
    end

    def auth_api_key
      "Bearer #{@api_key}"
    end

    # TODO: Remove
    # def base_path=(base_path)
    #   # Add leading and trailing slashes to base_path
    #   @base_path = "/#{base_path}".gsub(%r{/+}, "/")
    #   @base_path = "" if @base_path == "/"
    # end

    # TODO: Remove
    # Returns base URL for specified operation based on server settings
    # def base_url(operation = nil)
    #   index = server_operation_index.fetch(operation, server_index)
    #   return "#{scheme}://#{[host, base_path].join("/").gsub(%r{/+}, "/")}".sub(%r{/+\z}, "") if index.nil?

    #   server_url(index, server_operation_variables.fetch(operation, server_variables),
    #              operation_server_settings[operation])
    # end

    # Adds middleware to the stack
    def use(*middleware)
      set_faraday_middleware(:use, *middleware)
    end

    # Adds request middleware to the stack
    def request(*middleware)
      set_faraday_middleware(:request, *middleware)
    end

    # Adds response middleware to the stack
    def response(*middleware)
      set_faraday_middleware(:response, *middleware)
    end

    # Adds Faraday middleware setting information to the stack
    #
    # @example Use the `set_faraday_middleware` method to set middleware information
    #   config.set_faraday_middleware(:request, :retry, max: 3, methods: [:get, :post], retry_statuses: [503])
    #   config.set_faraday_middleware(:response, :logger, nil, { bodies: true, log_level: :debug })
    #   config.set_faraday_middleware(:use, Faraday::HttpCache, store: Rails.cache, shared_cache: false)
    #   config.set_faraday_middleware(:insert, 0, FaradayMiddleware::FollowRedirects, { standards_compliant: true, limit: 1 })
    #   config.set_faraday_middleware(:swap, 0, Faraday::Response::Logger)
    #   config.set_faraday_middleware(:delete, Faraday::Multipart::Middleware)
    #
    # @see https://github.com/lostisland/faraday/blob/v2.3.0/lib/faraday/rack_builder.rb#L92-L143
    def set_faraday_middleware(operation, key, *args, &block)
      unless %i[request response use insert insert_before insert_after swap delete].include?(operation)
        raise ArgumentError, "Invalid faraday middleware operation #{operation}. Must be" \
                             " :request, :response, :use, :insert, :insert_before, :insert_after, :swap or :delete."
      end

      @middlewares[operation] << [key, args, block]
    end
    ruby2_keywords(:set_faraday_middleware) if respond_to?(:ruby2_keywords, true)

    # Set up middleware on the connection
    def configure_middleware(connection)
      return if @middlewares.empty?

      %i[request response use insert insert_before insert_after swap].each do |operation|
        next unless @middlewares.key?(operation)

        @middlewares[operation].each do |key, args, block|
          connection.builder.send(operation, key, *args, &block)
        end
      end

      if @middlewares.key?(:delete)
        @middlewares[:delete].each do |key, _args, _block|
          connection.builder.delete(key)
        end
      end
    end
  end
end
