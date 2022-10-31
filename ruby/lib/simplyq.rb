# frozen_string_literal: true

# Version
require_relative "simplyq/version"

# API resources support classes
require "simplyq/errors"
require "simplyq/client"
require "simplyq/configuration"

# API models
require "simplyq/models/list"
require "simplyq/models/application"
require "simplyq/models/endpoint"
require "simplyq/models/event"
require "simplyq/models/delivery_attempt"

# APIs
require "simplyq/api/application_api"
require "simplyq/api/endpoint_api"
require "simplyq/api/event_api"

module Simplyq
end
