# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |resource|
      sign_in(resource)
    end
  end

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super do |resource|
      if token = params[:pending_vote_token].presence
        tmp_vote = Vote.find_by(pending_token: token)
        if !tmp_vote.nil?
          tmp_vote.confirm!(resource.main_profile)
        end
      end

      sign_in(resource)
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
