# frozen_string_literal: true

RSpec.describe Simplyq::API::EndpointAPI do
  subject(:api) { described_class.new(client) }

  let(:client) { Simplyq::Client.new(api_key: api_key, base_url: base_url) }
  let(:base_url) { "https://api.example.com" }
  let(:api_key) { "token" }

  let(:application_uid) { "app-id" }
  let(:endpoint_uid) { "fixture-edp-1" }

  describe "#retrieve" do
    it "returns the endpoint" do
      stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}})
        .to_return(http_fixture_for("GetEndpoint", status: 200))

      endpoint = api.retrieve(application_uid, endpoint_uid)

      expect(endpoint).to be_a(Simplyq::Model::Endpoint)
      expect(endpoint.uid).to eq("fixture-edp-1")
      expect(endpoint.url).to eq("https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1")
      expect(endpoint.headers).to be_a(Simplyq::Model::Endpoint::Headers)
      expect(endpoint.headers.headers).to eq({ "X-CUSTOM": "test" })
      expect(endpoint.headers.sensitive).to be(true)
    end
  end

  describe "#list" do
    it "returns a list of endpoints" do
      stub_request(:get, %r{/v1/application/#{application_uid}/endpoint})
        .to_return(http_fixture_for("GetEndpoints", status: 200))

      endpoints = api.list(application_uid)

      expect(endpoints).to be_a(Simplyq::Model::List)
      expect(endpoints.data).to be_a(Array)
      expect(endpoints.data.size).to eq(1)
      expect(endpoints.data.first).to be_a(Simplyq::Model::Endpoint)
      expect(endpoints.first.uid).to eq("fixture-edp-1")
      expect(endpoints.first.url).to eq("https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1")
    end

    context "when filters are provided" do
      it "returns a list of endpoints" do
        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint})
          .with(query: { "start_after" => "fixture-edp-1", "limit" => "1" })
          .to_return(http_fixture_for("GetEndpoints", status: 200))

        endpoints = api.list(application_uid, limit: 1, start_after: "fixture-edp-1")

        expect(endpoints).to be_a(Simplyq::Model::List)
        expect(endpoints.data).to be_a(Array)
        expect(endpoints.data.size).to eq(1)
        expect(endpoints.data.first).to be_a(Simplyq::Model::Endpoint)
        expect(endpoints.first.uid).to eq("fixture-edp-1")
        expect(endpoints.first.url).to eq("https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1")
      end
    end

    context "when using pagination" do
      it "returns a list of endpoints" do
        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetEndpoints", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint})
          .with(query: { "start_after" => "fixture-edp-1", "limit" => "1" })
          .to_return(http_fixture_for("GetEndpoints", status: 200))

        endpoints = api.list(application_uid, limit: 1)
        endpoints.has_more = true

        endpoints = endpoints.next_page

        expect(endpoints).to be_a(Simplyq::Model::List)
        expect(endpoints.first.uid).to eq("fixture-edp-1")
      end
    end
  end

  describe "#create" do
    it "creates an endpoint" do
      stub_request(:post, %r{/v1/application/#{application_uid}/endpoint})
        .with(body: hash_including({ "url" => "https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1" }))
        .to_return(http_fixture_for("PostEndpoint", status: 201))

      endpoint = api.create(application_uid, url: "https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1")

      expect(endpoint).to be_a(Simplyq::Model::Endpoint)
      expect(endpoint.uid).to eq("fixture-edp-1")
      expect(endpoint.url).to eq("https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/fixture-edp-1")
    end

    context "when the endpoint already exists" do
      it "raises an error" do
        stub_request(:post, %r{/v1/application/#{application_uid}/endpoint})
          .to_return(http_fixture_for("PostEndpoint", status: 422))

        expect do
          api.create(application_uid, { uid: "fixture-edp-1" })
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Invalid request")
          expect(error.errors).to eq([{ "error" => "Endpoint UID already exists in the application",
                                        "field" => "uid" }])
        end
      end
    end
  end

  describe "#update" do
    it "updates an endpoint" do
      stub_request(:put, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}})
        .with(body: hash_including({ "url" => "https://example.com/fixture-edp-1", "rate_limit" => 101 }))
        .to_return(http_fixture_for("PutEndpoint", status: 200))

      endpoint = api.update(application_uid, endpoint_uid, url: "https://example.com/fixture-edp-1", rate_limit: 101)

      expect(endpoint).to be_a(Simplyq::Model::Endpoint)
      expect(endpoint.uid).to eq("fixture-edp-1")
      expect(endpoint.rate_limit).to eq(101)
    end
  end

  describe "#delete" do
    it "deletes an endpoint" do
      stub_request(:delete, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}})
        .to_return(http_fixture_for("DeleteEndpoint", status: 204))

      expect(api.delete(application_uid, endpoint_uid)).to be(true)
    end

    context "when the endpoint does not exist" do
      it "raises an error" do
        stub_request(:delete, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}})
          .to_return(http_fixture_for("DeleteEndpoint", status: 404))

        expect do
          api.delete(application_uid, endpoint_uid)
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.code).to eq(404)
        end
      end
    end
  end

  describe "#recover" do
    it "recovers an endpoint" do
      time = Time.now.utc.iso8601
      stub_request(:post, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/recover})
        .with(body: hash_including({ "since" => time }))
        .to_return(http_fixture_for("PostEndpointRecover", status: 202))

      response = api.recover(application_uid, endpoint_uid, since: time)

      expect(response).to be(true)
    end

    context "when no valid time is provided" do
      it "raises an ArgumentError" do
        expect do
          api.recover(application_uid, endpoint_uid, since: "invalid")
        end.to raise_error(ArgumentError)
      end
    end

    context "when endpoint id does not exist" do
      it "raises an error" do
        stub_request(:post, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/recover})
          .to_return(http_fixture_for("PostEndpointRecover", status: 404))

        expect do
          api.recover(application_uid, endpoint_uid, since: Time.now.utc.iso8601)
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.code).to eq(404)
        end
      end
    end
  end

  describe "#retrieve_secret" do
    it "retrieves the endpoint secret" do
      stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/secret})
        .to_return(http_fixture_for("GetEndpointSecret", status: 200))

      secret = api.retrieve_secret(application_uid, endpoint_uid)

      expect(secret).to eq("enps_W9AVAEsWztO56sl1hNTxHWsJPlJ2nDon")
    end

    context "when the endpoint does not exist" do
      it "raises an error" do
        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/secret})
          .to_return(http_fixture_for("GetEndpointSecret", status: 404))

        expect do
          api.retrieve_secret(application_uid, endpoint_uid)
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.code).to eq(404)
        end
      end
    end
  end

  describe "#rotate_secret" do
    it "rotates the endpoint secret" do
      stub_request(:post, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/secret})
        .with(body: { key: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" })
        .to_return(http_fixture_for("PostEndpointSecretRotate", status: 204))

      result = api.rotate_secret(application_uid, endpoint_uid, secret: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

      expect(result).to be(true)
    end

    context "when the endpoint does not exist" do
      it "raises an error" do
        stub_request(:post, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/secret})
          .to_return(http_fixture_for("PostEndpointSecretRotate", status: 404))

        expect do
          api.rotate_secret(application_uid, endpoint_uid)
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.code).to eq(404)
        end
      end
    end
  end

  describe "#retrieve_attempted_events" do
    it "retrieves attempted events" do
      stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/event})
        .to_return(http_fixture_for("GetAttemptedEndpoints", status: 200))

      events = api.retrieve_attempted_events(application_uid, endpoint_uid)

      expect(events).to be_a(Simplyq::Model::List)
      expect(events.data).to be_a(Array)
      expect(events.size).to eq(1)
      expect(events.first).to be_a(Simplyq::Model::Event)
      expect(events.first.uid).to eq("evte_2GtKBoeEo99TijMnNH8QLPLeWWX")
    end

    context "when using pagination" do
      it "returns a list of events" do
        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/event})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetAttemptedEndpoints", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/event})
          .with(query: { "start_after" => "evte_2GtKBoeEo99TijMnNH8QLPLeWWX", "limit" => "1" })
          .to_return(http_fixture_for("GetAttemptedEndpoints", status: 200))

        events = api.retrieve_attempted_events(application_uid, endpoint_uid, limit: 1)
        events.has_more = true

        events = events.next_page

        expect(events).to be_a(Simplyq::Model::List)
        expect(events.first).to be_a(Simplyq::Model::Event)
        expect(events.first.uid).to eq("evte_2GtKBoeEo99TijMnNH8QLPLeWWX")
      end
    end
  end

  describe "#retrieve_delivery_attempts" do
    it "retrieves delivery attempts" do
      stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/delivery})
        .to_return(http_fixture_for("GetEndpointDeliveryAttempts", status: 200))

      attempts = api.retrieve_delivery_attempts(application_uid, endpoint_uid)

      expect(attempts).to be_a(Simplyq::Model::List)
      expect(attempts.data).to be_a(Array)
      expect(attempts.size).to eq(1)
      expect(attempts.first).to be_a(Simplyq::Model::DeliveryAttempt)
      expect(attempts.first.id).to eq("eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO")
    end

    context "when using pagination" do
      it "returns a list of delivery attempts" do
        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/delivery_attempt})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetEndpointDeliveryAttempts", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/delivery_attempt})
          .with(query: { "start_after" => "eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO", "limit" => "1" })
          .to_return(http_fixture_for("GetEndpointDeliveryAttempts", status: 200))

        attempts = api.retrieve_delivery_attempts(application_uid, endpoint_uid, limit: 1)
        attempts.has_more = true

        attempts = attempts.next_page

        expect(attempts).to be_a(Simplyq::Model::List)
        expect(attempts.first).to be_a(Simplyq::Model::DeliveryAttempt)
        expect(attempts.first.id).to eq("eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO")
      end
    end
  end

  describe "#build_model" do
    it "builds a model" do
      endpoint = api.build_model({ uid: endpoint_uid, url: "https://example.com/fixture-edp-1" })

      expect(endpoint).to be_a(Simplyq::Model::Endpoint)
      expect(endpoint.uid).to eq("fixture-edp-1")
      expect(endpoint.url).to eq("https://example.com/fixture-edp-1")
    end
  end

  describe "#decerialize_list" do
    it "builds a list" do
      list = api.decerialize_list({ data: [{ uid: endpoint_uid, url: "https://example.com/fixture-edp-1" }] }.to_json)

      expect(list).to be_a(Simplyq::Model::List)
      expect(list.data).to be_a(Array)
      expect(list.data.size).to eq(1)
      expect(list.data.first).to be_a(Simplyq::Model::Endpoint)
      expect(list.data.first.uid).to eq("fixture-edp-1")
      expect(list.data.first.url).to eq("https://example.com/fixture-edp-1")
    end
  end

  describe "#_to_rfc3339" do
    it "converts a time to RFC3339" do
      expect(api._to_rfc3339(Time.utc(2020, 1, 1, 0, 0, 0))).to eq("2020-01-01T00:00:00Z")
    end

    it "converts a datetime to RFC3339" do
      expect(api._to_rfc3339(DateTime.new(2020, 1, 1, 0, 0, 0))).to eq("2020-01-01T00:00:00Z")
    end

    it "converts a string to RFC3339" do
      expect(api._to_rfc3339("2020-01-01T00:00:00Z")).to eq("2020-01-01T00:00:00Z")
    end

    context "when timezone is not UTC" do
      it "converts a time to RFC3339" do
        expect(api._to_rfc3339(Time.new(2020, 1, 1, 0, 0, 0, "+09:00"))).to eq("2019-12-31T15:00:00Z")
      end

      it "converts a datetime to RFC3339" do
        expect(api._to_rfc3339(DateTime.new(2020, 1, 1, 0, 0, 0, "+09:00"))).to eq("2019-12-31T15:00:00Z")
      end

      it "converts a string to RFC3339" do
        expect(api._to_rfc3339("2020-01-01T00:00:00+09:00")).to eq("2019-12-31T15:00:00Z")
      end
    end

    context "when the value is invalid" do
      it "raises an error" do
        expect do
          api._to_rfc3339("invalid")
        end.to raise_error(ArgumentError) do |error|
          expect(error.message).to eq("no time information in \"invalid\"")
        end
      end

      it "raises an error when date provided" do
        expect do
          api._to_rfc3339(Date.new(2020, 1, 1))
        end.to raise_error(ArgumentError) do |error|
          expect(error.message).to eq("Invalid time must be a Time, DateTime, String")
        end
      end
    end
  end
end
