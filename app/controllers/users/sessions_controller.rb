# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  def new
    # If email is provided, show the password step
    if params[:email].present?
      @email = params[:email]
      self.resource = resource_class.new(email: @email)
      render :password_step
    else
      super
    end
  end

  # POST /resource/sign_in
  def create
    # If password not provided, it means we're on the first step
    if params[:user].nil? || params[:user][:password].nil?
      @email = params[:email]
      if @email.present?
        @user = User.find_by(email: @email)
        if @user
          redirect_to new_user_session_path(email: @email)
        else
          flash.now[:alert] = "We couldn't find an account with that email address."
          self.resource = resource_class.new
          render :new
        end
      else
        flash.now[:alert] = "Please enter your email address."
        self.resource = resource_class.new
        render :new
      end
    else
      super
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || my_root_path
  end
end
