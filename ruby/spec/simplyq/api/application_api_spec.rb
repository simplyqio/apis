# frozen_string_literal: true

RSpec.describe Simplyq::API::ApplicationAPI do
  subject(:api) { described_class.new(client) }

  let(:client) { Simplyq::Client.new(api_key: api_key, base_url: base_url) }
  let(:base_url) { "https://api.example.com" }
  let(:api_key) { "token" }

  describe "#retrieve" do
    it "returns the application" do
      stub_request(:get, %r{/v1/application/123})
        .to_return(http_fixture_for("GetApplication", status: 200))

      application = api.retrieve("123")

      expect(application).to be_a(Simplyq::Model::Application)
      expect(application.uid).to eq("test-app-11")
      expect(application.name).to eq("Application Test 11")
      expect(application.retry_strategy).to be_a(Simplyq::Model::Application::RetryStrategy)
      expect(application.retry_strategy.type).to eq("base_exponential_backoff_with_deadline")
    end

    context "when the application does not exist" do
      it "raises an error" do
        stub_request(:get, %r{/v1/application/123})
          .to_return(http_fixture_for("GetApplication", status: 404))

        expect { api.retrieve("123") }.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.param).to be_nil
        end
      end
    end
  end

  describe "#list" do
    it "returns a list of applications" do
      stub_request(:get, %r{/v1/application})
        .to_return(http_fixture_for("GetApplications", status: 200))

      applications = api.list

      expect(applications).to be_a(Simplyq::Model::List)
      expect(applications.data).to be_a(Array)
      expect(applications.data.size).to eq(2)
      expect(applications.data.first).to be_a(Simplyq::Model::Application)
      expect(applications.first.uid).to eq("test-app-11")
      expect(applications.first.name).to eq("Application Test 11")
    end

    context "when filters are provided" do
      it "returns a list of applications" do
        stub_request(:get, %r{/v1/application})
          .with(query: { "start_after" => "test-app-11", "limit" => "1" })
          .to_return(http_fixture_for("GetApplications", status: 200))

        applications = api.list(limit: 1, start_after: "test-app-11")

        expect(applications).to be_a(Simplyq::Model::List)
        expect(applications.data.first).to be_a(Simplyq::Model::Application)
        expect(applications.filters).to eq({ limit: 1, start_after: "test-app-11" })
      end
    end

    context "when using pagination" do
      it "returns a list of applications" do
        stub_request(:get, %r{/v1/application})
          .with(query: { "limit" => "1" })
          .to_return(http_fixture_for("GetApplications", status: 200))

        stub_request(:get, %r{/v1/application})
          .with(query: { "start_after" => "fixture-1", "limit" => "1" })
          .to_return(http_fixture_for("GetApplications", status: 200))

        applications = api.list(limit: 1)

        next_page = applications.next_page

        expect(next_page).to be_a(Simplyq::Model::List)
        expect(next_page.first).to be_a(Simplyq::Model::Application)
        expect(next_page.filters).to eq({ limit: 1, start_after: "fixture-1" })
      end
    end
  end

  describe "#create" do
    it "returns the application" do
      stub_request(:post, %r{/v1/application})
        .with(body: hash_including({ "name" => "Fixture app", "uid" => "fixture-1" }))
        .to_return(http_fixture_for("PostApplication", status: 201))

      application = api.create(name: "Fixture app", uid: "fixture-1")

      expect(application).to be_a(Simplyq::Model::Application)
      expect(application.uid).to eq("fixture-1")
      expect(application.name).to eq("Fixture app")
      expect(application.retry_strategy).to be_a(Simplyq::Model::Application::RetryStrategy)
      expect(application.retry_strategy.type).to eq("base_exponential_backoff_with_deadline")
    end

    context "when the application already exists" do
      it "raises an error" do
        stub_request(:post, %r{/v1/application})
          .with(body: hash_including({ "name" => "Fixture app", "uid" => "fixture-1" }))
          .to_return(http_fixture_for("PostApplication", status: 422))

        expect do
          api.create(name: "Fixture app", uid: "fixture-1")
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Invalid request")
          expect(error.errors).to eq(
            [{ error: "Application UID already exists in your account", field: "uid" }]
          )
        end
      end
    end
  end

  describe "#update" do
    it "returns the application" do
      stub_request(:put, %r{/v1/application/fixture-1})
        .with(body: hash_including({ "name" => "Fixture app (Updated)" }))
        .to_return(http_fixture_for("PutApplication", status: 200))

      application = api.update("fixture-1", name: "Fixture app (Updated)")

      expect(application).to be_a(Simplyq::Model::Application)
      expect(application.uid).to eq("fixture-1")
      expect(application.name).to eq("Fixture app (Updated)")
    end

    context "when updating the retry strategy" do
      it "returns the application" do
        stub_request(:put, %r{/v1/application/fixture-1})
          .with(body: hash_including(
            {
              "retry_strategy" => hash_including(
                {
                  "type" => "fixed_wait",
                  "max_retries" => 10
                }
              )
            }
          ))
          .to_return(http_fixture_for("PutApplication", status: 200))

        application = api.update("fixture-1", retry_strategy: { type: "fixed_wait", max_retries: 10 })

        expect(application).to be_a(Simplyq::Model::Application)
        expect(application.uid).to eq("fixture-1")
        expect(application.name).to eq("Fixture app (Updated)")
        expect(application.retry_strategy).to be_a(Simplyq::Model::Application::RetryStrategy)
        expect(application.retry_strategy.type).to eq("fixed_wait")
        expect(application.retry_strategy.max_retries).to eq(10)
      end
    end

    context "when the application does not exist" do
      it "raises an error" do
        stub_request(:put, %r{/v1/application/does-not-exist})
          .with(body: hash_including({ "name" => "Fixture app" }))
          .to_return(http_fixture_for("PutApplication", status: 404))

        expect do
          api.update("does-not-exist", name: "Fixture app")
        end.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.param).to be_nil
        end
      end
    end
  end

  describe "#delete" do
    it "returns true" do
      stub_request(:delete, %r{/v1/application/fixture-1})
        .to_return(http_fixture_for("DeleteApplication", status: 204))

      expect(api.delete("fixture-1")).to be(true)
    end

    context "when the application does not exist" do
      it "raises an error" do
        stub_request(:delete, %r{/v1/application/does-not-exist})
          .to_return(http_fixture_for("DeleteApplication", status: 404))

        expect { api.delete("does-not-exist") }.to raise_error(Simplyq::InvalidRequestError) do |error|
          expect(error.message).to eq("Resource not found")
          expect(error.param).to be_nil
        end
      end
    end
  end
end
