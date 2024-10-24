class BallotsController < ApplicationController
  before_action :authenticate_user!

  def show
    @ballot = Ballot.includes(:questions).find(params[:id])
    if @ballot.private? && !@ballot.invited?(current_user)
      redirect_to root_path, alert: "You are not allowed to view that ballot."
    end
  end
end
