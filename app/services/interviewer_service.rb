class InterviewerService
  def initialize(question)
    @question = question
  end

  def generate_follow_up(answer_text)
    messages = [
      {
        role: "system",
        content: "#{@question.prompt}\n\nThe question being asked is: #{@question.body}\n\nBased on the user's answer, ask a relevant follow-up question."
      },
      {
        role: "user",
        content: answer_text
      }
    ]

    MistralService.new.chat(messages)
  end
end
