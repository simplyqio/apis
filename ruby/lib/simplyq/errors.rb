# frozen_string_literal: true

module Simplyq
  class SimplyqError < StandardError
    # @return [SimplyqResponse] response object that conveys basic information
    # about the response that triggered the error
    attr_accessor :response

    attr_reader :message
    attr_reader :code
    attr_reader :error
    attr_reader :http_status
    attr_reader :http_headers
    attr_reader :http_body
    attr_reader :json_body
    attr_reader :request_id

    def initialize(message = nil, http_status: nil, http_body: nil,
                   http_headers: nil, code: nil, error: nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @json_body = parse_body
      @http_headers = http_headers || {}
      @code = code
      @request_id = @http_headers["request-id"]
      @error = error
    end

    def parse_body
      return if @http_body.nil?

      @json_body = JSON.parse(@http_body, symbolize_names: true)
    rescue JSON::ParserError
      @json_body = nil
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      id_string = @request_id.nil? ? "" : "(Request #{@request_id}) "
      "#{status_string}#{id_string}#{@message}"
    end
  end

  # AuthenticationError is raised when invalid credentials are used to connect
  # to SimplyQ's servers.
  class AuthenticationError < SimplyqError
  end

  # APIConnectionError is raised in the event that the SDK can't connect to
  # SimplyQ's servers. Reasons vary from a network split to bad TLS certs.
  class APIConnectionError < SimplyqError
  end

  # APIError is a general error, that can be raised when other errors are not
  # appropriate. It can also be used to raise new errors that have been added
  # to the API but not yet added to the SDK or not in the current version.
  class APIError < SimplyqError
  end

  # InvalidRequestError is raised when a request data is found to be invalid.
  class InvalidRequestError < SimplyqError
    attr_accessor :param
    attr_accessor :errors

    def initialize(message, param, http_status: nil, http_body: nil,
                   http_headers: nil, code: nil, error: nil, errors: [])
      super(message, http_status: http_status, http_body: http_body,
                     http_headers: http_headers,
                     code: code)
      @param = param
      @errors = errors
    end
  end

  # PaymentRequiredError is raised when your ccount is in bad standing or
  # exceeded the quota limits on the free plan.
  # Please go to your account's billing page or reach out to support.
  class PaymentRequiredError < SimplyqError
  end

  # RateLimitError is raised when your account is putting too much pressure on
  # SimplyQ's server. Please back off on request rate, or reach out to support.
  class RateLimitError < SimplyqError
  end

  # PermissionError is raised when your account does not have the right
  # permissions to perform an action.
  class PermissionError < SimplyqError
  end

  # SignatureVerificationError is raised when the signature verification for a
  # webhook fails
  class SignatureVerificationError < SimplyqError
  end
end
