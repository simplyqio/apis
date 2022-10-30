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
end
