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
end
