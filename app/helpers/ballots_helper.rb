module BallotsHelper
  def format_end_date(end_date)
    now = Time.current
    tomorrow = 1.day.from_now.beginning_of_day
    today = now.beginning_of_day

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
end
