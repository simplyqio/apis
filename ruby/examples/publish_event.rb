# frozen_string_literal: true

# rubocop:disable Layout/FirstHashElementIndentation

$LOAD_PATH << "#{File.expand_path("..", __dir__)}/lib"

require "simplyq"

# Create and Configure a new Client
client = Simplyq::Client.new({
  api_key: ENV.fetch("SIMPLYQ_API_KEY")
})

# Create an Application
application = client.applications.create({
  uid: "example-app-1",
  name: "Example App 1"
})

# Create an endpoint
_endpoint = client.endpoints.create(application.uid, {
  uid: "example-endpoint-1",
  url: "https://webhook.site/1b2d263c-37db-4b09-9512-489afb959b0a/example-endpoint-1",
  description: "Example Endpoint 1"
})

# Publish an event
event = client.events.create(application.uid, {
  event_type: "example.event",
  payload: {
    message: "Hello World!"
  }
})

# Get the delivery attempts for the event
delivery_attempts = client.events.retrieve_delivery_attempts(application.uid, event.uid)

delivery_attempts.each do |delivery_attempt|
  puts "Delivery Attempt #{delivery_attempt.id} for Event #{event.uid} was #{delivery_attempt.status}"
  puts "  Response: #{delivery_attempt.response}"
  puts "  Response Code: #{delivery_attempt.response_status_code}"
end

# rubocop:enable Layout/FirstHashElementIndentation
