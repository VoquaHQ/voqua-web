require "net/http"
require "json"

class SmsService
  SEVEN_IO_URL = URI("https://gateway.seven.io/api/sms")

  class DeliveryError < StandardError; end

  def self.send_otp(phone_e164, code)
    new.send_otp(phone_e164, code)
  end

  def send_otp(phone_e164, code)
    if !Rails.env.production?
      Rails.logger.info "[SmsService] OTP: #{code}"
      return true
    end

    api_key = ENV["SEVEN_IO_API_KEY"] || Rails.application.credentials.seven_io_api_key



    raise DeliveryError, "seven.io API key not configured" if api_key.blank?

    body = { to: phone_e164, text: "Your Voqua code: #{code}", from: "Voqua" }.to_json

    http = Net::HTTP.new(SEVEN_IO_URL.host, SEVEN_IO_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(SEVEN_IO_URL)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = body

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise DeliveryError, "SMS delivery failed: #{response.code} #{response.body}"
    end

    true
  end
end
