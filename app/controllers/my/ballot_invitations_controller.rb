class My::BallotInvitationsController < My::BaseController
  before_action :set_ballot

  def bulk_create
    emails = params[:emails].split(/[\n,]/).map(&:strip).reject(&:empty?)
    errors_count = 0
    emails.each do |email|
      invitation = @ballot.invitations.create(email: email)
      if invitation.persisted?
        BallotInvitationMailer.invite(@ballot, invitation).deliver
      else
        errors_count += 1
      end
    end

    flash[:success] = "#{emails.size - errors_count} invitations created successfully."
    redirect_to my_ballot_path(@ballot)
  end

  def destroy
    @invitation = @ballot.invitations.find(params[:id])
    @invitation.destroy
    flash[:success] = "Invitation deleted successfully."
    redirect_to my_ballot_path(@ballot)
  end

  private

  def set_ballot
    @ballot = current_user.main_profile.owned_ballots.find_by!(slug: params[:ballot_id])
  end
end
