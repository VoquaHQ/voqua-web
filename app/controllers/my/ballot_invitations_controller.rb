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

    redirect_to my_ballot_path(@ballot), notice: "#{emails.size - errors_count} invitations created successfully."
  end

  def destroy
    @invitation = @ballot.invitations.find(params[:id])
    @invitation.destroy
    redirect_to my_ballot_path(@ballot), notice: "Invitation deleted successfully."
  end

  private

  def set_ballot
    @ballot = current_user.ballots.find(params[:ballot_id])
  end
end
