module BallotsHelper
  def votes_count_fields_for(ballot, question_id, type, votes)
    votes_count = 0
    if votes && question_votes = votes.data[question_id.to_s]
      votes_count = question_votes[type.to_s].to_i
    end
    render "votes_count_fields", question_id: question_id, type: type, votes_count: votes_count
  end
end
