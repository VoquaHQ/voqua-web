class My::DashboardController < My::BaseController
  def index
    profile = current_user.main_profile

    @ballots = profile.ballots
                      .includes(profile: :user)
                      .includes(:votes)
                      .order(created_at: :desc)
                      .limit(5)

    @voted_status = @ballots.each_with_object({}) do |ballot, hash|
      hash[ballot.id] = ballot.votes.any? { |v| v.profile_id == profile.id }
    end

    @questions = profile.questions
                        .order(created_at: :desc)
                        .limit(5)
  end
end
