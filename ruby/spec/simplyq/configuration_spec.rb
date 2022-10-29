# frozen_string_literal: true

RSpec.describe Simplyq::Configuration do
  it "initializes the configuration with defaults" do
    config = described_class.new

    expect(config.api_key).to be_nil
    expect(config.base_url).to eq("https://api.simplyq.io")
    expect(config.timeout).to eq(30)
  end

  describe "::default" do
    it "returns the default configuration" do
      expect(described_class.default).to be_a(described_class)
    end
  end
end
