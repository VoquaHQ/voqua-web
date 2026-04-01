Rails.application.routes.draw do
  match "(*any)",
    to: redirect(subdomain: ""),
    via: :all,
    constraints: { subdomain: "www" }

  devise_for :users, controllers: {
    # sessions: 'users/sessions'
    registrations: "users/registrations",
    sessions: "devise/passwordless/sessions",
    confirmations: "users/confirmations",
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    namespace :users do
      get "custom_magic_link", to: "custom_magic_link#show"
    end
  end


  # devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  namespace :my do
    root "dashboard#index"
    resources :questions do
      member do
        post :try_answer
      end
    end
    resources :ballots do
      resources :options do
        member do
          post :generate
        end
      end

      resources :ballot_invitations do
        collection do
          post :bulk_create
        end
      end
    end
  end

  resources :questions, only: [:show] do
    member do
      post :answer
      post :follow_up_answer
      post :request_otp
      post :verify_otp
    end
  end

  resources :ballots, only: [:show] do
    member do
      get :results
      post :submit_votes
      post :phone_verification
      post :request_otp
      get  :otp_verification
      post :verify_otp
      get  :vote_confirmed
    end

    get "/invite/:token", to: "ballot_invitations#accept", as: :accept_invitation
  end
end
