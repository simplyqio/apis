# frozen_string_literal: true

RSpec.describe Simplyq::Model::Event do
  subject(:model) { described_class.new(data) }

  let(:data) do
    {
      uid: "uid-1",
      event_type: "test.event",
      topics: ["apac-region"],
      payload: { foo: "bar" },
      retention_period: 5,
      created_at: "2021-03-01T00:00:00Z"
    }
  end

  describe "initialization" do
    it "can be initialized with a hash" do
      expect { model }.not_to raise_error
      expect(model.uid).to eq(data[:uid])
      expect(model.event_type).to eq(data[:event_type])
      expect(model.payload).to eq(data[:payload])
      expect(model.retention_period).to eq(data[:retention_period])
      expect(model.topics).to eq(data[:topics])
      expect(model.created_at).to eq(data[:created_at])
    end
  end

  describe "#from_hash" do
    it "can be initialized with a hash" do
      model = described_class.from_hash(data)
      expect(model.uid).to eq(data[:uid])
      expect(model.event_type).to eq(data[:event_type])
      expect(model.payload).to eq(data[:payload])
      expect(model.retention_period).to eq(data[:retention_period])
      expect(model.topics).to eq(data[:topics])
      expect(model.created_at).to eq(data[:created_at])
    end
  end

  describe "#to_h" do
    it "returns a hash" do
      model = described_class.new(data)
      expect(model.to_h).to eq(data)
    end
  end

  describe "#to_json" do
    it "returns a JSON string" do
      model = described_class.new(data)
      expect(model.to_json).to eq(data.to_json)
    end
  end

  describe "#==" do
    it "returns true if the objects are equal" do
      model1 = described_class.new(data)
      model2 = described_class.new(data)
      expect(model1).to eq(model2)
    end

    it "returns false if the objects are not equal" do
      model1 = described_class.new(data)
      model2 = described_class.new(data.merge(uid: "uid-2"))
      expect(model1).not_to eq(model2)
    end
  end

  describe "#validation_errors" do
    it "returns an empty array if the model is valid" do
      model = described_class.new(data)
      expect(model.validation_errors).to eq([])
    end

    it "returns an array of validation errors if the model is invalid" do
      model = described_class.new(data.merge(uid: "invalid@uid 1", event_type: "invalid.event:type", retention_period: 91))
      expect(model.validation_errors).to eq(
        [
          "invalid value for \"uid\", must conform to the pattern (?-mix:^[a-zA-Z0-9\\-_.]+$).",
          "invalid value for \"event_type\", must conform to the pattern (?-mix:^[a-zA-Z0-9\\-_.]+$).",
          "invalid value for \"retention_period\", must be smaller than or equal to 90."
        ]
      )
    end
  end
end
