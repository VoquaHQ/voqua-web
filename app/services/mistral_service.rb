require "net/http"
require "json"

class MistralService
  API_URL = URI("https://api.mistral.ai/v1/chat/completions")

  class ApiError < StandardError; end

  def initialize(model: "mistral-small-latest")
    @model = model
    @api_key = Rails.application.credentials.mistral_api_key || ENV["MISTRAL_API_KEY"]
    raise ApiError, "Mistral API key not configured" if @api_key.blank?
  end

  def chat(messages)
    http = Net::HTTP.new(API_URL.host, API_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(API_URL)
    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json"
    request.body = { model: @model, messages: messages }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise ApiError, "Mistral API error: #{response.code} #{response.body}"
    end

    parsed = JSON.parse(response.body)
    parsed.dig("choices", 0, "message", "content")
  end
end
