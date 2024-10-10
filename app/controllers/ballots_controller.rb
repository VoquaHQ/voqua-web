class BallotsController < ApplicationController
  before_action :authenticate_user!

  def show
    @ballot = current_user.ballots.includes(:questions).find(params[:id])
  end
end
