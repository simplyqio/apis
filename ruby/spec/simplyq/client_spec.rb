# frozen_string_literal: true

RSpec.describe Simplyq::Client do
  describe "initialization" do
    it "does not raise when no configuration is provided" do
      expect { described_class.new }.not_to raise_error
    end

    context "allows to set configuration options as a hash" do
      it "accepts :base_url option" do
        subject = described_class.new(base_url: "https://api.example.com")
        expect(subject.config.base_url).to eq("https://api.example.com")
      end

      it "set :api_key option" do
        subject = described_class.new(api_key: "token")
        expect(subject.config.api_key).to eq("token")
      end
    end

    context "allows to set configuration options as a block" do
      it "accepts :base_url option" do
        config = Simplyq::Configuration.setup do |config|
          config.base_url = "https://api.example.com"
        end
        subject = described_class.new(config)
        expect(subject.config.base_url).to eq("https://api.example.com")
      end
    end

    context "when no valid configuration is provided" do
      it "raises an error" do
        config = nil

        expect { described_class.new(config) }.to raise_error(ArgumentError) do |error|
          expect(error.message).to eq("Invalid configuration options #{config}")
        end
      end
    end
  end

  describe "request authentication" do
    let(:base_url) { "https://api.example.com" }

    it "requests have an Authorization header" do
      stub_request(:get, %r{/test})

      subject = described_class.new(api_key: "token", base_url: base_url)
      subject.call_api(:get, "test", {})

      expect(WebMock).to have_requested(:get, "#{base_url}/test")
        .with(headers: { "Authorization" => "Bearer token" })
    end

    context "when the request is unauthorized" do
      it "raises an error" do
        stub_request(:get, %r{/test}).to_return(http_fixture_for("GetApplications", status: 401))

        subject = described_class.new(api_key: "token", base_url: base_url)

        expect { subject.call_api(:get, "test", {}) }.to raise_error(Simplyq::AuthenticationError) do |error|
          expect(error.message).to eq("Unauthorized")
        end
      end
    end

    context "when no API key is provided" do
      it "raises an error" do
        subject = described_class.new(base_url: base_url)

        expect { subject.call_api(:get, "test", {}) }.to raise_error(Simplyq::AuthenticationError) do |error|
          expect(error.message).to eq("No API key provided.")
        end
      end

      it "raises an error when API key is invalid" do
        subject = described_class.new(api_key: "invalid token", base_url: base_url)

        expect { subject.call_api(:get, "test", {}) }.to raise_error(Simplyq::AuthenticationError) do |error|
          expect(error.message).to eq("Invalid API key as it includes spaces")
        end
      end
    end
  end

  describe "#call_api" do
    subject(:api) { described_class.new(api_key: api_key, base_url: base_url) }

    let(:api_key) { "token" }
    let(:base_url) { "https://api.example.com" }

    it "requests have a Content-Type header" do
      stub_request(:get, %r{/test})

      api.call_api(:get, "test", {})

      expect(WebMock).to have_requested(:get, "#{base_url}/test")
        .with(headers: { "Content-Type" => "application/json" })
    end

    it "requests have a User-Agent header" do
      stub_request(:get, %r{/test})

      api.call_api(:get, "test", {})

      expect(WebMock).to have_requested(:get, "#{base_url}/test")
        .with(headers: { "User-Agent" => Simplyq::Client::USER_AGENT })
    end

    it "correctly applies query parameters" do
      stub_request(:get, %r{/test})

      query_params = { bar: "baz", fizz: %w[buzz bazz] }

      api.call_api(:get, "test", { query_params: query_params })

      expect(WebMock).to have_requested(:get, "#{base_url}/test")
        .with(query: query_params)
    end

    it "correctly applies additional headers" do
      stub_request(:get, %r{/test})

      headers = { "X-Test" => "test" }

      api.call_api(:get, "test", { header_params: headers })

      expect(WebMock).to have_requested(:get, "#{base_url}/test")
        .with(headers: headers)
    end

    it "correctly applies request body" do
      stub_request(:post, %r{/test})

      body = { foo: "bar" }

      api.call_api(:post, "test", { body: body })

      expect(WebMock).to have_requested(:post, "#{base_url}/test")
        .with(body: body)
    end

    context "when the request fails" do
      it "raises an error with the error message" do
        stub_request(:get, %r{/test})
          .to_return(status: 500, body: { error: "Internal Server Error", code: 500 }.to_json)

        expect { api.call_api(:get, "test", {}) }.to raise_error(Simplyq::APIError) do |error|
          expect(error.message).to eq("Internal Server Error")
          expect(error.http_status).to eq(500)
        end
      end

      it "raises an error with the error message and code" do
        stub_request(:get, %r{/test}).to_return(status: 500,
                                                body: {
                                                  error: "Internal Server Error", code: "internal_server_error"
                                                }.to_json)

        expect { api.call_api(:get, "test", {}) }.to raise_error(Simplyq::APIError) do |error|
          expect(error.message).to eq("Internal Server Error")
          expect(error.code).to eq("internal_server_error")
        end
      end

      it "raises an error with the error message and code and status and headers" do
        stub_request(:get, %r{/test}).to_return(status: 500,
                                                body: { error: "Internal Server Error", code: "internal_server_error", status: 500 }.to_json, headers: { "X-Test" => "test" })

        expect { api.call_api(:get, "test", {}) }.to raise_error(Simplyq::APIError) do |error|
          expect(error.message).to eq("Internal Server Error")
          expect(error.code).to eq("internal_server_error")
          expect(error.http_status).to eq(500)
          expect(error.http_headers).to eq("x-test" => "test")
        end
      end

      it "raises an error when request times out" do
        stub_request(:get, %r{/test}).to_timeout

        expected_message = Simplyq::Client::ERROR_MESSAGE_CONNECTION % base_url
        expected_message += "\n\n(Network error: execution expired)"
        expect { api.call_api(:get, "test", {}) }.to raise_error(Simplyq::APIConnectionError) do |error|
          expect(error.message).to eq(expected_message)
        end
      end

      it "raises an error when request raises SSL error" do
        stub_request(:get, %r{/test}).to_raise(Faraday::SSLError)

        expected_message = Simplyq::Client::ERROR_MESSAGE_SSL % base_url
        expected_message += "\n\n(Network error: Exception from WebMock)"
        expect { api.call_api(:get, "test", {}) }.to raise_error(Simplyq::APIConnectionError) do |error|
          expect(error.message).to eq(expected_message)
        end
      end

      it "raises an error when request is invalid" do
        stub_request(:post, %r{/test})
          .to_return(http_fixture_for("PostApplication", status: 422))

        expect do
          api.call_api(:post, "test", {})
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Invalid request")
          expect(error.errors).to eq(
            [{
              "error" => "Application UID already exists in your account",
              "field" => "uid"
            }]
          )
        end
      end
    end
  end

  describe "#connection" do
    let(:api_key) { "token" }
    let(:base_url) { "https://api.example.com" }

    context "when proxy is set" do
      it "requests are made through the proxy" do
        proxy = "https://username:password@proxy.example.com:8080"

        api = described_class.new(api_key: api_key, base_url: base_url, proxy: proxy)
        connection = subject.connection

        expect(connection.proxy).to eq(Faraday::ProxyOptions.from(proxy))
      end
    end
  end
end
