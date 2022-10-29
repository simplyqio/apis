# frozen_string_literal: true

RSpec.describe Simplyq::Model::List do
  subject(:model) { described_class.new(data_type, data, api: api, filters: filters) }

  let(:api) { instance_spy(Simplyq::API::ApplicationAPI) }
  let(:filters) { { start_after: "uid-1", limit: 2 } }
  let(:data) { { data: [], has_more: false } }
  let(:data_type) { Hash }

  describe "initialization" do
    it "can be initialized with a hash" do
      expect { model }.not_to raise_error
      expect(model).to be_a(described_class)
      expect(model.data).to eq([])
      expect(model.has_more).to be_falsy
      expect(model.filters).to eq(filters)
      expect(model.data_type).to eq(data_type)
      expect(model.api).to eq(api)
    end

    it "can be initialized with serializable data" do
      data_type = Simplyq::Model::Application
      data = { data: [{}], has_more: false }
      model = described_class.new(data_type, data, api: api, filters: filters)
      expect(model.data).to eq([data_type.new({})])
      expect(model.has_more).to be_falsy
      expect(model.filters).to eq(filters)
      expect(model.data_type).to eq(data_type)
      expect(model.api).to eq(api)
    end
  end

  describe "#from_hash" do
    it "can be initialized with a hash" do
      expect { model }.not_to raise_error
      expect(model).to be_a(described_class)
      expect(model.data).to eq([])
      expect(model.has_more).to be_falsy
      expect(model.filters).to eq(filters)
      expect(model.data_type).to eq(data_type)
      expect(model.api).to eq(api)
    end
  end

  describe "#next_page" do
    it "returns nil when there is no next page" do
      expect(model.next_page).to be_nil
    end

    it "calls the API to get the next page" do
      data = { data: [{ uid: "uid-1" }, { uid: "uid-2" }], has_more: true }
      data_type = Simplyq::Model::Application
      model = described_class.new(data_type, data, api: api, filters: filters)

      expect(api).to receive(:list)
        .with(filters.merge(start_after: "uid-2"))

      model.next_page
    end
  end

  describe "#prev_page" do
    it "returns nil when there is no previous page" do
      expect(model.prev_page).to be_nil
    end

    it "calls the API to get the previous page" do
      data = { data: [{ uid: "uid-1" }, { uid: "uid-2" }], has_more: true }
      data_type = Simplyq::Model::Application
      model = described_class.new(data_type, data, api: api, filters: filters)

      expect(api).to receive(:list)
        .with(ending_before: "uid-1", limit: 2)

      model.prev_page
    end
  end

  describe "#[]" do
    context "when key is an integer" do
      it "returns the element at the given index" do
        data = { data: [{}, {}], has_more: false }
        model = described_class.new(data_type, data, api: api, filters: filters)
        expect(model[0]).to eq(data_type.new({}))
        expect(model[1]).to eq(data_type.new({}))
      end
    end

    context "when key is a string" do
      it "returns the element with the given uid" do
        expect(model[:data]).to eq([])
        expect(model["has_more"]).to be_falsy
      end
    end
  end

  describe "#each" do
    it "yields each element" do
      data = { data: [{}, {}], has_more: false }
      model = described_class.new(data_type, data, api: api, filters: filters)
      expect { |b| model.each(&b) }.to yield_successive_args(data_type.new({}), data_type.new({}))
    end
  end

  describe "#==" do
    it "returns true when the other object is the same" do
      expect(model).to eq(model)
    end

    it "returns true when the other object has the same data" do
      other = described_class.new(data_type, data, api: api, filters: filters)
      expect(model).to eq(other)
    end

    it "returns false when the other object has different data" do
      other = described_class.new(data_type, { data: [{}, {}], has_more: false }, api: api, filters: filters)
      expect(model).not_to eq(other)
    end

    it "returns false when the other object is not a list" do
      expect(model).not_to eq([])
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the list" do
      expect(model.to_h).to eq(data)
    end

    it "returns a hash representation of the list with serializable data" do
      data_type = Simplyq::Model::Application
      data = { data: [{}], has_more: false }
      model = described_class.new(data_type, data, api: api, filters: filters)
      expected_data = { data: [data_type.new({}).to_h], has_more: false }
      expect(model.to_h).to eq(expected_data)
    end
  end

  describe "#to_json" do
    it "returns a json representation of the list" do
      expect(model.to_json).to eq(data.to_json)
    end

    it "returns a json representation of the list with serializable data" do
      data_type = Simplyq::Model::Application
      data = { data: [{}], has_more: false }
      model = described_class.new(data_type, data, api: api, filters: filters)
      expected_data = { data: [data_type.new({}).to_h], has_more: false }
      expect(model.to_json).to eq(expected_data.to_json)
    end
  end
end
