# frozen_string_literal: true

RSpec.describe Simplyq::API::EventAPI do
  subject(:api) { described_class.new(client) }

  let(:client) { Simplyq::Client.new(api_key: api_key, base_url: base_url) }
  let(:base_url) { "https://api.example.com" }
  let(:api_key) { "token" }

  let(:application_uid) { "app-id" }
  let(:endpoint_uid) { "fixture-edp-1" }
  let(:event_uid) { "fixture-event-1" }

  describe "#retrieve" do
    it "retrieves an event" do
      stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}})
        .to_return(http_fixture_for("GetEvent", status: 200))

      event = api.retrieve(application_uid, event_uid)

      expect(event).to be_a(Simplyq::Model::Event)
      expect(event.uid).to eq(event_uid)
      expect(event.event_type).to eq("fixture.created")
      expect(event.topics).to eq(%w[a])
      expect(event.retention_period).to eq(0)
      expect(event.payload).to eq({ data: { client: "ruby", shard: 2 }, type: "sample.event" })
    end
  end

  describe "#list" do
    it "lists events" do
      stub_request(:get, %r{/v1/application/#{application_uid}/event})
        .to_return(http_fixture_for("GetEvents", status: 200))

      events = api.list(application_uid)

      expect(events).to be_a(Simplyq::Model::List)
      expect(events.size).to eq(2)
      expect(events.data).to be_a(Array)
      expect(events.first).to be_a(Simplyq::Model::Event)
    end

    context "when filters are provided" do
      it "lists events" do
        stub_request(:get, %r{/v1/application/#{application_uid}/event})
          .with(query: { event_types: ["fixture.created"] })
          .to_return(http_fixture_for("GetEvents", status: 200))

        events = api.list(application_uid, event_types: ["fixture.created"])

        expect(events).to be_a(Simplyq::Model::List)
        expect(events.size).to eq(2)
        expect(events.data).to be_a(Array)
        expect(events.first).to be_a(Simplyq::Model::Event)
      end
    end

    context "when pagination is provided" do
      it "lists events" do
        stub_request(:get, %r{/v1/application/#{application_uid}/event})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetEvents", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/event})
          .with(query: { "start_after" => "fixture-event-2", "limit" => "1" })
          .to_return(http_fixture_for("GetEvents", status: 200))

        events = api.list(application_uid, limit: 1)
        events.has_more = true

        events.next_page
      end
    end
  end

  describe "#create" do
    let(:data) do
      {
        uid: "fixture-event-2",
        event_type: "fixture.created",
        topics: %w[a],
        retention_period: 0,
        payload: { data: { client: "ruby", shard: 2 }, type: "sample.event" }
      }
    end

    it "creates an event" do
      stub_request(:post, %r{/v1/application/#{application_uid}/event})
        .to_return(http_fixture_for("PostEvent", status: 201))

      event = api.create(application_uid, data)

      expect(event).to be_a(Simplyq::Model::Event)
      expect(event.uid).to eq("fixture-event-2")
      expect(event.event_type).to eq("fixture.created")
      expect(event.topics).to eq(%w[a])
      expect(event.retention_period).to eq(0)
      expect(event.payload).to eq({ data: { client: "ruby", shard: 2 }, type: "sample.event" })
    end

    context "when event uid already exists" do
      it "raises an error" do
        stub_request(:post, %r{/v1/application/#{application_uid}/event})
          .to_return(http_fixture_for("PostEvent", status: 422))

        expect { api.create(application_uid, data) }.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Invalid request")
          expect(error.errors).to eq([{ "error" => "Event UID already exists in the application", "field" => "uid" }])
        end
      end
    end
  end

  describe "#retrieve_delivery_attempts" do
    it "retrieves delivery attempts" do
      stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/delivery_attempt})
        .to_return(http_fixture_for("GetEventDeliveryAttempts", status: 200))

      attempts = api.retrieve_delivery_attempts(application_uid, event_uid)

      expect(attempts).to be_a(Simplyq::Model::List)
      expect(attempts.data).to be_a(Array)
      expect(attempts.size).to eq(1)
      expect(attempts.first).to be_a(Simplyq::Model::DeliveryAttempt)
      expect(attempts.first.id).to eq("eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO")
    end

    context "when using pagination" do
      it "returns a list of delivery attempts" do
        stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/delivery_attempt})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetEventDeliveryAttempts", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/delivery_attempt})
          .with(query: { "start_after" => "eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO", "limit" => "1" })
          .to_return(http_fixture_for("GetEventDeliveryAttempts", status: 200))

        attempts = api.retrieve_delivery_attempts(application_uid, event_uid, limit: 1)
        attempts.has_more = true

        attempts = attempts.next_page

        expect(attempts).to be_a(Simplyq::Model::List)
        expect(attempts.first).to be_a(Simplyq::Model::DeliveryAttempt)
        expect(attempts.first.id).to eq("eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO")
      end
    end
  end

  describe "#retrieve_endpoints" do
    it "retrieves endpoints" do
      stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/endpoint})
        .to_return(http_fixture_for("GetEventEndpoints", status: 200))

      endpoints = api.retrieve_endpoints(application_uid, event_uid)

      expect(endpoints).to be_a(Simplyq::Model::List)
      expect(endpoints.data).to be_a(Array)
      expect(endpoints.size).to eq(1)
      expect(endpoints.first).to be_a(Simplyq::Model::Endpoint)
      expect(endpoints.first.uid).to eq("fixture-edp-1")
    end

    context "when using pagination" do
      it "returns a list of endpoints" do
        stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/endpoint})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetEventEndpoints", status: 200))

        stub_request(:get, %r{/v1/application/#{application_uid}/event/#{event_uid}/endpoint})
          .with(query: { "start_after" => "fixture-edp-1", "limit" => "1" })
          .to_return(http_fixture_for("GetEventEndpoints", status: 200))

        endpoints = api.retrieve_endpoints(application_uid, event_uid, limit: 1)
        endpoints.has_more = true

        endpoints = endpoints.next_page

        expect(endpoints).to be_a(Simplyq::Model::List)
        expect(endpoints.first).to be_a(Simplyq::Model::Endpoint)
        expect(endpoints.first.uid).to eq("fixture-edp-1")
      end
    end
  end

  describe "#retry" do
    it "retries an event" do
      stub_request(:post, %r{/v1/application/#{application_uid}/endpoint/#{endpoint_uid}/event/#{event_uid}})
        .to_return(http_fixture_for("PostEventRetry", status: 202))

      result = api.retry(application_uid, endpoint_uid, event_uid)

      expect(result).to be(true)
    end
  end

  describe "#retrieve_delivery_attempt" do
    it "retrieves a delivery attempt" do
      delivery_attempt_id = "eda_2GtK307736Bqy1uZeyApkIhgxBV1ETMIO"

      stub_request(:get,
                   %r{/v1/application/#{application_uid}/event/#{event_uid}/delivery_attempt/#{delivery_attempt_id}/})
        .to_return(http_fixture_for("GetDeliveryAttempt", status: 200))

      attempt = api.retrieve_delivery_attempt(application_uid, event_uid, delivery_attempt_id)

      expect(attempt).to be_a(Simplyq::Model::DeliveryAttempt)
      expect(attempt.id).to eq(delivery_attempt_id)
    end
  end
end
