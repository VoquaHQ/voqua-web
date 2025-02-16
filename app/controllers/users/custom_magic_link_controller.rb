class Users::CustomMagicLinkController < Devise::MagicLinksController
  def show
    super do |resource|
      if token = params[:user] && params[:user][:pending_vote_token].presence
        tmp_vote = Vote.find_by(pending_token: token)
        if !tmp_vote.nil?
          tmp_vote.confirm!(resource.main_profile)
          sign_in(resource)
        end
      end
    end
  end
end
