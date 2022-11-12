# frozen_string_literal: true

RSpec.describe Simplyq::Model::Endpoint do
  subject(:model) { described_class.new(data) }

  let(:data) { {} }

  describe "initialization" do
    it "can be initialized with a hash" do
      expect { model }.not_to raise_error
      expect(model).to be_a(described_class)
      expect(model.uid).to be_nil
      expect(model.url).to be_nil
      expect(model.version).to be_nil
      expect(model.description).to be_nil
      expect(model.filter_types).to be_nil
      expect(model.topics).to be_nil
      expect(model.active).to be_nil
      expect(model.rate_limit).to be_nil
      expect(model.headers).to be_a(Simplyq::Model::Endpoint::Headers)
      expect(model.secret).to be_nil
      expect(model.created_at).to be_nil
      expect(model.updated_at).to be_nil
    end

    it "can be initialized with serializable data" do
      data = {
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { "header" => "value" },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.uid).to eq("uid-1")
      expect(model.url).to eq("https://example.com")
      expect(model.version).to eq("v1")
      expect(model.description).to eq("description")
      expect(model.filter_types).to eq(["filter_type"])
      expect(model.topics).to eq(["topic"])
      expect(model.active).to be_truthy
      expect(model.rate_limit).to eq(100)
      expect(model.headers).to be_a(Simplyq::Model::Endpoint::Headers)
      expect(model.headers.to_h).to eq(headers: nil, sensitive: nil)
      expect(model.secret).to eq("secret")
      expect(model.created_at).to eq("2021-03-01T00:00:00Z")
      expect(model.updated_at).to eq("2021-03-01T00:00:00Z")
    end
  end

  describe "#from_hash" do
    it "can be initialized with a hash" do
      data = {
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { "header" => "value" },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.from_hash(data)
      expect(model.uid).to eq("uid-1")
      expect(model.url).to eq("https://example.com")
      expect(model.version).to eq("v1")
      expect(model.description).to eq("description")
      expect(model.filter_types).to eq(["filter_type"])
      expect(model.topics).to eq(["topic"])
      expect(model.active).to be_truthy
      expect(model.rate_limit).to eq(100)
      expect(model.headers).to be_a(Simplyq::Model::Endpoint::Headers)
      expect(model.headers.to_h).to eq(headers: nil, sensitive: nil)
      expect(model.secret).to eq("secret")
      expect(model.created_at).to eq("2021-03-01T00:00:00Z")
      expect(model.updated_at).to eq("2021-03-01T00:00:00Z")
    end
  end

  describe "#validation_errors" do
    it "returns an empty array when valid" do
      data = {
        url: "https://example.com",
        version: "v1"
      }
      model = described_class.new(data)
      expect(model.validation_errors).to eq([])
    end

    it "returns an array of errors when invalid" do
      data = {
        uid: "uid@1",
        description: "description",
        filter_types: ["filter_type"],
        topics: %w[a b c d e f],
        rate_limit: 0,
        headers: { "header" => "value" },
        secret: "secret"
      }
      model = described_class.new(data)
      expect(model.validation_errors).to eq(
        [
          "invalid value for \"uid\", must conform to the pattern (?-mix:^[a-zA-Z0-9\\-_.]+$).",
          "invalid value for \"url\", url cannot be nil.",
          "invalid value for \"version\", version cannot be nil.",
          "invalid value for \"topics\", number of items must be less than or equal to 5.",
          "invalid value for \"rate_limit\", must be greater than or equal to 1."
        ]
      )
    end
  end

  describe "#valid?" do
    it "returns true when valid" do
      data = {
        url: "https://example.com",
        version: "v1"
      }
      model = described_class.new(data)
      expect(model).to be_valid
    end

    it "returns false when invalid" do
      data = {
        uid: "uid@1",
        description: "description",
        filter_types: ["filter_type"],
        topics: %w[a b c d e f],
        rate_limit: 0,
        headers: { "header" => "value" },
        secret: "secret"
      }
      model = described_class.new(data)
      expect(model).not_to be_valid
    end
  end

  describe "#==" do
    let(:data) do
      {
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { "header" => "value" },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      }
    end

    it "returns true when equal" do
      model = described_class.new(data)
      other = described_class.new(data)
      expect(model).to eq(other)
    end

    it "returns false when not equal" do
      model = described_class.new(data)
      other = described_class.new(data.merge(uid: "uid-2"))
      expect(model).not_to eq(other)
    end
  end

  describe "#[]" do
    it "returns the value for the given key" do
      data = {
        uid: "uid-1",
        url: "https://example.com"
      }
      model = described_class.new(data)
      expect(model[:uid]).to eq("uid-1")
      expect(model[:url]).to eq("https://example.com")
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the model" do
      data = {
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { headers: { header: "value" } },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.to_h).to eq(
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { headers: { header: "value" }, sensitive: nil },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      )
    end
  end

  describe "#to_json" do
    it "returns a json representation of the model" do
      data = {
        uid: "uid-1",
        url: "https://example.com",
        version: "v1",
        description: "description",
        filter_types: ["filter_type"],
        topics: ["topic"],
        active: true,
        rate_limit: 100,
        headers: { headers: { header: "value" }, sensitive: nil },
        secret: "secret",
        created_at: "2021-03-01T00:00:00Z",
        updated_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.to_json).to eq(data.to_json)
    end
  end

  describe Simplyq::Model::Endpoint::Headers do
    describe "#has_sensitive?" do
      it "returns true when sensitive headers present" do
        data = {
          headers: { "header" => "value" },
          sensitive: { "sensitive" => "value" }
        }
        model = described_class.new(data)
        expect(model).to have_sensitive
      end

      it "returns false when no sensitive headers are present" do
        data = {
          headers: { "header" => "value" },
          sensitive: {}
        }
        model = described_class.new(data)
        expect(model).not_to have_sensitive
      end
    end

    describe "#[]" do
      it "returns the value for the given key" do
        headers = described_class.new(headers: { "header" => "value" })
        expect(headers[:headers]).to eq("header" => "value")
      end
    end

    describe "#to_h" do
      it "returns a hash representation of the model" do
        data = { headers: { header: "value" }, sensitive: nil }
        model = described_class.new(data)
        expect(model.to_h).to eq(headers: { header: "value" }, sensitive: nil)
      end
    end

    describe "#to_json" do
      it "returns a json representation of the model" do
        data = { headers: { header: "value" }, sensitive: nil }
        model = described_class.new(data)
        expect(model.to_json).to eq(data.to_json)
      end
    end
  end
end
