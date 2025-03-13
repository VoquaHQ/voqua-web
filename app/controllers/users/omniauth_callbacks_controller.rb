# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  #
  def google_oauth2
    user = User.from_google(from_google_params)

    if user.present?
      sign_out_all_scopes
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      # Set remember_me to true to make the session last longer
      sign_in_and_redirect user, event: :authentication, remember_me: true
    else
      flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end
  end

  def entra_id
    user = User.from_microsoft(from_google_params)

    if user.present?
      sign_out_all_scopes
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Microsoft'
      # Set remember_me to true to make the session last longer
      sign_in_and_redirect user, event: :authentication, remember_me: true
    else
      flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Microsoft'
      redirect_to new_user_session_path
    end
  end

  private

  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      email: auth.info.email
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
