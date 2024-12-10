class BallotInvitationsController < ApplicationController
  before_action :authenticate_user!

  def accept
    invitation = BallotInvitation.find_by!(token: params[:token])
    if invitation.accept!(current_user.main_profile)
      redirect_to my_ballots_path, notice: "Invitation accepted successfully."
    else
      redirect_to root_path, alert: "Failed to accept invitation: #{invitation.errors.full_messages.to_sentence}"
    end
  end
end
