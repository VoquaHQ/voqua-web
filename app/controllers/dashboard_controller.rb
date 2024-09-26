class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_ballots = current_user.ballots
    @accessible_ballots = Ballot.where.not(user: current_user).where('deadline > ?', Time.current)
  end
end
