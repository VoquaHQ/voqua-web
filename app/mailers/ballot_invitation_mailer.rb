class BallotInvitationMailer < ApplicationMailer
  def invite(ballot, invitation)
    @ballot = ballot
    @invitation = invitation
    @inviter_email = ballot.profile.user.email
    @url = ballot_accept_invitation_url(@ballot, token: invitation.token)
    mail(
      to: invitation.email,
      subject: "You're invited to participate in a vote on Voqua"
    )
  end
end
