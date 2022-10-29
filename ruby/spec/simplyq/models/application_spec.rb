# frozen_string_literal: true

RSpec.describe Simplyq::Model::Application do
  subject(:api) { instance_spy(Simplyq::API::ApplicationAPI) }

  describe "initialization" do
    it "can be initialized with a hash" do
      application = nil
      expect { application = described_class.new({}) }.not_to raise_error
      expect(application).to be_a(described_class)
      expect(application.uid).to be_nil
      expect(application.name).to be_nil
      expect(application.rate_limit).to be_nil
      expect(application.retry_strategy).to be_a(Simplyq::Model::Application::RetryStrategy)
    end
  end

  describe "#from_hash" do
    it "can be initialized with a hash" do
      application = nil
      expect { application = described_class.new({}) }.not_to raise_error
      expect(application).to be_a(described_class)
      expect(application.uid).to be_nil
      expect(application.name).to be_nil
      expect(application.rate_limit).to be_nil
      expect(application.retry_strategy).to be_a(Simplyq::Model::Application::RetryStrategy)
    end
  end

  describe "#validation_errors" do
    it "returns an empty array when the object is valid" do
      application = described_class.new(uid: "foo", name: "bar")
      expect(application.validation_errors).to eq([])
    end

    it "returns an array with the errors when the object is invalid" do
      application = described_class.new({})
      application.uid = "invalid@uid"
      expect(application.validation_errors)
        .to eq([
                 "invalid value for \"uid\", must conform to the pattern (?-mix:^[a-zA-Z0-9\\-_.]+$).",
                 "invalid value for \"name\", name cannot be nil."
               ])
    end

    it "validates nested objects" do
      application = described_class.new({ uid: "foo", name: "bar", retry_strategy: { type: "invalid" } })
      expect(application.validation_errors)
        .to eq(["retry_strategy.invalid value for \"type\", must be one of base_exponential_backoff_with_deadline, exponential_backoff, exponential_backoff_with_deadline, fixed_wait, fixed_wait_with_deadline."])
    end
  end

  describe "#valid?" do
    it "returns true when the object is valid" do
      application = described_class.new(uid: "foo", name: "bar")
      expect(application.valid?).to be(true)
    end

    it "returns false when the object is invalid" do
      application = described_class.new({})
      application.uid = "invalid@uid"
      expect(application.valid?).to be(false)
    end

    it "validates nested objects" do
      application = described_class.new({ uid: "foo", name: "bar", retry_strategy: { type: "invalid" } })
      expect(application.valid?).to be(false)
    end
  end

  describe "#[]" do
    it "returns the value for the given key" do
      application = described_class.new(uid: "foo", name: "bar")
      expect(application[:uid]).to eq("foo")
      expect(application[:name]).to eq("bar")
    end

    it "returns nil when the key is not found" do
      application = described_class.new(uid: "foo", name: "bar")
      expect(application[:invalid]).to be_nil
    end
  end

  describe "#==" do
    it "returns true when the objects are equal" do
      application1 = described_class.new(uid: "foo", name: "bar")
      application2 = described_class.new(uid: "foo", name: "bar")
      expect(application1).to eq(application2)
    end

    it "returns false when the objects are not equal" do
      application1 = described_class.new(uid: "foo", name: "bar")
      application2 = described_class.new(uid: "foo", name: "bar2")
      expect(application1).not_to eq(application2)
    end
  end

  describe "#to_h" do
    it "returns a hash representation of the object" do
      application = described_class.new(uid: "foo", name: "bar")
      expected_hash = {
        uid: "foo",
        name: "bar",
        rate_limit: nil,
        retry_strategy: Simplyq::Model::Application::RetryStrategy.new({}).to_h,
        created_at: nil,
        updated_at: nil
      }
      expect(application.to_h).to eq(expected_hash)
    end
  end

  describe "#to_json" do
    it "returns a json representation of the object" do
      application = described_class.new(uid: "foo", name: "bar")
      expected_json = {
        uid: "foo",
        name: "bar",
        rate_limit: nil,
        retry_strategy: Simplyq::Model::Application::RetryStrategy.new({}).to_h,
        created_at: nil,
        updated_at: nil
      }.to_json
      expect(application.to_json).to eq(expected_json)
    end
  end

  describe Simplyq::Model::Application::RetryStrategy do
    describe "initialization" do
      it "can be initialized with a hash" do
        retry_strategy = nil
        expect { retry_strategy = described_class.new({}) }.not_to raise_error
        expect(retry_strategy).to be_a(described_class)
        expect(retry_strategy.type).to eq(described_class::DEFAULT_TYPE)
        expect(retry_strategy.max_retries).to be_nil
        expect(retry_strategy.deadline).to be_nil
      end
    end

    describe "#from_hash" do
      it "can be initialized with a hash" do
        retry_strategy = nil
        expect { retry_strategy = described_class.new({}) }.not_to raise_error
        expect(retry_strategy).to be_a(described_class)
        expect(retry_strategy.type).to eq(described_class::DEFAULT_TYPE)
        expect(retry_strategy.max_retries).to be_nil
        expect(retry_strategy.deadline).to be_nil
      end
    end

    describe "#validation_errors" do
      it "returns an empty array when the object is valid" do
        retry_strategy = described_class.new(type: "fixed_wait")
        expect(retry_strategy.validation_errors).to eq([])
      end

      it "returns an array with the errors when the object is invalid" do
        retry_strategy = described_class.new({})
        retry_strategy.type = "invalid"
        expect(retry_strategy.validation_errors)
          .to eq([
                   "invalid value for \"type\", must be one of base_exponential_backoff_with_deadline, exponential_backoff, exponential_backoff_with_deadline, fixed_wait, fixed_wait_with_deadline."
                 ])
      end
    end

    describe "#valid?" do
      it "returns true when the object is valid" do
        retry_strategy = described_class.new(type: "fixed_wait")
        expect(retry_strategy.valid?).to be(true)
      end

      it "returns false when the object is invalid" do
        retry_strategy = described_class.new({})
        retry_strategy.type = "invalid"
        expect(retry_strategy.valid?).to be(false)
      end
    end

    describe "#[]" do
      it "returns the value for the given key" do
        retry_strategy = described_class.new(type: "fixed_wait")
        expect(retry_strategy[:type]).to eq("fixed_wait")
      end
    end

    describe "#==" do
      it "returns true when the objects are equal" do
        retry_strategy1 = described_class.new(type: "fixed_wait")
        retry_strategy2 = described_class.new(type: "fixed_wait")
        expect(retry_strategy1).to eq(retry_strategy2)
      end

      it "returns false when the objects are not equal" do
        retry_strategy1 = described_class.new(type: "fixed_wait")
        retry_strategy2 = described_class.new(type: "fixed_wait_with_deadline")
        expect(retry_strategy1).not_to eq(retry_strategy2)
      end
    end

    describe "#to_h" do
      it "returns a hash representation of the object" do
        retry_strategy = described_class.new(type: "fixed_wait")
        expected_hash = {
          type: "fixed_wait",
          retry_delay: nil,
          max_retries: nil,
          deadline: nil
        }
        expect(retry_strategy.to_h).to eq(expected_hash)
      end
    end

    describe "#to_json" do
      it "returns a json representation of the object" do
        retry_strategy = described_class.new(type: "fixed_wait")
        expected_json = {
          type: "fixed_wait",
          max_retries: nil,
          retry_delay: nil,
          deadline: nil
        }.to_json
        expect(retry_strategy.to_json).to eq(expected_json)
      end
    end
  end
end
