# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    # If email is provided, show the password step
    if params[:email].present?
      @email = params[:email]
      build_resource(email: @email)
      resource.build_main_profile(handle: params[:handle])
      render :password_step
    else
      super do |user|
        user.build_main_profile(handle: params[:handle])
      end
    end
  end

  # POST /resource
  def create
    # If password not provided, it means we're on the first step
    if params[:user].nil? || params[:user][:password].nil?
      @email = params[:email]
      if @email.present?
        if User.find_by(email: @email)
          build_resource
          resource.errors.add(:email, :taken)
          render :new
        else
          redirect_to new_user_registration_path(email: @email)
        end
      else
        build_resource
        resource.errors.add(:email, :blank)
        render :new
      end
    else
      super do |user|
        user.build_main_profile if user.main_profile.nil?
        user.profiles << user.main_profile
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [main_profile_attributes: [:handle]])
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
