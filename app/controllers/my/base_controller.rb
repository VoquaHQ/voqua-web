class My::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invitations

  layout "my"

  def check_invitations
    @invitations = BallotInvitation.where(email: current_user.email, accepted_at: nil).includes(:ballot)
  end
end
