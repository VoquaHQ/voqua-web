module BallotsHelper
  def votes_count_fields_for(ballot, option_id, type, votes)
    votes_count = 0
    if votes && option_votes = votes.data[option_id.to_s]
      votes_count = option_votes[type.to_s].to_i
    end
    render "votes_count_fields", option_id: option_id, type: type, votes_count: votes_count
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

  def for_each_ballot_result(results, options)
    results.each.with_index do |result, i|
      option = options.find { |q| q.id == result[:option_id] }
      yield result, option, i
    end
  end

  def ballot_text_summary(ballot, results)
    summary = []
    summary << "Here are the results of the Voqua on \"#{ballot.name}\":"
    summary << ""
    results.each_with_index do |result, i|
      option = ballot.options.find { |q| q.id == result[:option_id] }
      votes = result[:value]
      summary << "#{i + 1}. #{option.title} (#{votes >= 0 ? '+' : ''}#{votes} votes)"
    end
    summary << ""
    summary << "Link to Voqua ballot: #{ballot_url(ballot)}"
    summary.join("\n")
  end
end
