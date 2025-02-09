class Users::CustomMagicLinkController < Devise::MagicLinksController
  def show
    super do |resource|
      if token = params[:user] && params[:user][:tmp_vote_token].presence
        tmp_vote = TmpVote.find_by(token: token)
        if !tmp_vote.nil? && tmp_vote.confirmed_at.nil?
          tmp_vote.update!(confirmed_at: Time.current)
          Vote.create!(ballot: tmp_vote.ballot, profile: resource.main_profile, data: tmp_vote.data)
          BallotMembership.create!(ballot: tmp_vote.ballot, profile: resource.main_profile)
          sign_in(resource)
        end
      end
    end
  end
end
