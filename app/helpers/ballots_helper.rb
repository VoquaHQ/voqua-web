module BallotsHelper
  def votes_count_fields_for(ballot, question_id, type, votes)
    votes_count = 0
    if votes && question_votes = votes.data[question_id.to_s]
      votes_count = question_votes[type.to_s].to_i
    end
    render "votes_count_fields", question_id: question_id, type: type, votes_count: votes_count
  end

  def format_end_date(end_date)
    now = Time.current
    tomorrow = 1.day.from_now.beginning_of_day

    if end_date < now
      "Completed #{end_date.strftime("%B %-d, %Y")}"
    elsif end_date < tomorrow
      "Ends today at #{end_date.strftime("%-I:%M %p")}"
    elsif end_date < tomorrow.end_of_day
      "Ends tomorrow at #{end_date.strftime("%-I:%M %p")}"
    else
      "Open until #{end_date.strftime("%B %-d, %Y")}"
    end
  end

  def vote_results_for(question_id, results)
    votes = results[question_id.to_s] || { for: 0, against: 0 }
    votes_for = votes[:for]
    votes_against = votes[:against]
    value = votes_for - votes_against
    if value < 0
      value = 0
    end

    value
  end
end
