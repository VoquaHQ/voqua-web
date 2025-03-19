module AI
  class BallotBuilder
    SYSTEM_MESSAGE = <<~EOS
      You are a helpful assistant that helps creating ballot with options for a group of people to vote on.
      Based on the user's input, understand the problem and the possible options discussed in the user message.
      Don't add any new options, unless they are explicitly asked for by the user.
      Understand the user and generate a Ballot in json format.
    EOS

    JSON_SCHEMA = {
      strict: true,
      name: "Ballot",
      schema: {
        title: "Ballot",
        description: "A Ballot is a question with a collection of options that can be answered by a group of people.",
        type: "object",
        additionalProperties: false,
        required: ["name", "description", "options"],
        properties: {
          name: {
            type: "string"
          },
          description: {
            type: "string"
          },
          options: {
            type: "array",
            items: {
              type: "object",
              additionalProperties: false,
              required: ["title"],
              properties: {
                title: {
                  type: "string"
                }
              }
            }
          }
        }
      }
    }

    def initialize
      @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)
    end

    def generate_options user_message
      resp = @client.chat(parameters: {
        model: "gpt-4o-mini",
        response_format: {
          type: "json_schema",
          json_schema: JSON_SCHEMA
        } ,
        messages: [
          {
            role: :system,
            content: SYSTEM_MESSAGE
          },
          {
            role: :user,
            content: user_message
          }
        ]
      })

      j = JSON.parse (resp["choices"][0]["message"]["content"])
      options = j["options"].map do |o|
        BallotOption.new(title: o["title"])
      end

      {
        name: j["name"],
        description: j["description"],
        options: options,
      }
    end
  end
end
