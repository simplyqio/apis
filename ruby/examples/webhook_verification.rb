# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
Bundler.require :default

require "sinatra/base"

class WebhookVerification < Sinatra::Base
  set :port, 9090

  helpers do
    def request_headers
      env.each_with_object({}) do |(k, v), acc|
        acc[::Regexp.last_match(1).downcase] = v if k =~ /^http_(.*)/i
      end
    end
  end

  post(%r{/webhook.*}) do
    event = Simplyq::Webhook.construct_event(
      request.body.read,
      signatures: request_headers["x_simplyq_signature"],
      timestamp: request_headers["x_simplyq_timestamp"],
      secret: ENV.fetch("SIMPLYQ_WEBHOOK_SECRET")
    )

    pp event.data

    return 200
  end
end

WebhookVerification.run!
