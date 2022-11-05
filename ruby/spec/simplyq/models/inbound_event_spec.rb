# frozen_string_literal: true

RSpec.describe Simplyq::Model::InboundEvent do
  subject(:model) { described_class.new(data) }

  let(:data) { {} }

  describe "initialization" do
    it "can be initialized with a hash" do
      expect { model }.not_to raise_error
      expect(model).to be_a(described_class)
      expect(model.data).to eq({})
    end

    it "can be initialized with serializable data" do
      data = {
        uid: "uid-1",
        type: "type",
        data: { "key" => "value" },
        created_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.data).to eq(data)
    end
  end

  describe "#from_hash" do
    it "can be initialized with a hash" do
      data = {
        uid: "uid-1",
        type: "type",
        data: { "key" => "value" },
        created_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.from_hash(data)
      expect(model.data).to eq(data)
    end
  end

  describe "#to_h" do
    it "returns a hash" do
      data = {
        uid: "uid-1",
        type: "type",
        data: { "key" => "value" },
        created_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.to_h).to eq(data)
    end
  end

  describe "#to_json" do
    it "returns a JSON string" do
      data = {
        uid: "uid-1",
        type: "type",
        data: { "key" => "value" },
        created_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model.to_json).to eq(data.to_json)
    end
  end

  describe "#[]" do
    it "returns a value" do
      data = {
        uid: "uid-1",
        type: "type",
        data: { "key" => "value" },
        created_at: "2021-03-01T00:00:00Z"
      }
      model = described_class.new(data)
      expect(model[:uid]).to eq("uid-1")
      expect(model[:type]).to eq("type")
      expect(model[:data]).to eq("key" => "value")
      expect(model[:created_at]).to eq("2021-03-01T00:00:00Z")
    end
  end
end
