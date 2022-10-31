# frozen_string_literal: true

require_relative "lib/simplyq/version"

Gem::Specification.new do |spec|
  spec.name = "simplyq"
  spec.version = Simplyq::VERSION
  spec.authors = ["simplyq-dxtimer"]
  spec.email = ["ivan@simplyq.io"]

  spec.summary = "The SimplyQ API client for Ruby"
  spec.description = "The SimplyQ API client for Ruby"
  spec.homepage = "https://github.com/simplyqio/apis"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/simplyqio/apis/tree/main/ruby"
  spec.metadata["changelog_uri"] = "https://github.com/simplyqio/apis/tree/main/ruby/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", [">= 0.15", "< 2.0"]
  spec.add_dependency "multi_json", "~> 1.0"
  spec.add_dependency "net-http-persistent"
  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # We are looking to automate the release process so MFA is not supported yet
  # spec.metadata["rubygems_mfa_required"] = "true"
end
