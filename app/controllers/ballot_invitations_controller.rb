class BallotInvitationsController < ApplicationController
  before_action :authenticate_user!

  def accept
    invitation = BallotInvitation.find_by!(token: params[:token])
    if invitation.accept!(current_user.main_profile)
      flash[:success] = "Invitation accepted successfully."
      redirect_to my_ballots_path
    else
      flash[:error] = "Failed to accept invitation: #{invitation.errors.full_messages.to_sentence}"
      redirect_to root_path
    end
  end
end
