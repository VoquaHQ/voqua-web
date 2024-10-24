class BallotInvitationMailer < ApplicationMailer
  def invite(ballot, invitation)
    @ballot = ballot
    @invitation = invitation
    @url = ballot_accept_invitation_url(@ballot, token: invitation.token)
    mail to: invitation.email, subject: "You have been invited to vote"
  end
end
