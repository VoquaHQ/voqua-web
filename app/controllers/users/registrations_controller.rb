# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    if params[:email].present? && params[:first_name].present?
      # Show password step (final)
      @email = params[:email]
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      build_resource(email: @email, first_name: @first_name, last_name: @last_name)
      resource.build_main_profile(handle: params[:handle])
      render :password_step
    elsif params[:email].present?
      # Show name step
      @email = params[:email]
      build_resource(email: @email)
      resource.build_main_profile(handle: params[:handle])
      render :name_step
    else
      # Show email step
      super do |user|
        user.build_main_profile(handle: params[:handle])
      end
    end
  end

  # POST /resource
  def create
    if params[:user].nil?
      # First step - email validation
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
    elsif params[:user][:password].nil?
      # Second step - name validation
      @email = params[:user][:email]
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      
      if @first_name.present?
        redirect_to new_user_registration_path(
          email: @email,
          first_name: @first_name,
          last_name: @last_name
        )
      else
        build_resource(email: @email)
        resource.errors.add(:first_name, :blank)
        render :name_step
      end
    else
      # Final step - create user with password validation
      if params[:user][:password] != params[:user][:password_confirmation]
        build_resource(sign_up_params)
        resource.errors.add(:password_confirmation, :confirmation)
        render :password_step
      else
        super do |user|
          user.build_main_profile if user.main_profile.nil?
          user.profiles << user.main_profile
        end
      end
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, main_profile_attributes: [:handle]])
  end
end
