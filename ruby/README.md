# SimplyQ Ruby Client

[![Ruby CI](https://github.com/simplyqio/apis/actions/workflows/ruby-ci.yml/badge.svg?branch=main)](https://github.com/simplyqio/apis/actions/workflows/ruby-ci.yml) [![Gem Version](https://badge.fury.io/rb/simplyq.svg)](https://badge.fury.io/rb/simplyq)

The Ruby client for the [SimplyQ API](https://development.simplyq.io)

[SimplyQ](https://simplyq.io) distributes your events, with the Webhooks API you can send and manage your webhooks reliably and easily.

## Installation

Install the gem and add to the application's Gemfile by executing:

    ```shell
    bundle add simplyq
    ```

If bundler is not being used to manage dependencies, install the gem by executing:

    ```shell
    gem install simplyq
    ```

## Usage

```ruby
# Load the gem
require 'simplyq'

# Setup the client
client = Simplyq::Client.new({
  # Configure Bearer authorization (bmp_2dNkUE1XXXXXXXXXXXXXXXXXXXXXXXXXXXXX): HTTPBearer
  api_key: ENV.fetch("SIMPLYQ_API_KEY")
})

app = {
    uid: 'example-app-1',
    name: 'Example application #1'
}

# Create an application
app = client.applications.create(app)
```

You can find more examples in the [examples](examples) directory. And also our API reference site which has examples of the ruby client https://developer.simplyq.io.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/simplyqio/apis, please first open an issue before opening a PR so we can discuss the changes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/simplyqio/apis/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Simplyq project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/simplyqio/apis/blob/main/CODE_OF_CONDUCT.md).
