# frozen_string_literal: true

module RSpecWebhookHelpers
  def generate_headers_for(payload, secret, timestamp: Time.now.utc.to_i)
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret, "#{timestamp}#{payload}"))

    {
      "x-simplyq-signature" => signature,
      "x-simplyq-timestamp" => timestamp.to_s
    }
  end
end

RSpec.configure do |config|
  config.include RSpecWebhookHelpers
end
