# frozen_string_literal: true

module RSpecSupportHelpers
  def http_fixture_for(operation, status:)
    File.read(File.join(File.expand_path("..", __dir__), "fixtures", "#{operation}.#{status}.http"))
  end

  def http_fixture(*file_names)
    File.join(File.expand_path("..", __dir__), "fixtures", *file_names)
  end

  def read_http_fixture(...)
    File.read(http_fixture(...))
  end
  ruby2_keywords(:read_http_fixture) if respond_to?(:ruby2_keywords, true)
end

RSpec.configure do |config|
  config.include RSpecSupportHelpers
end
