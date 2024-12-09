Rails.application.routes.draw do
  match "(*any)",
    to: redirect(subdomain: ""),
    via: :all,
    constraints: { subdomain: "www" }


  devise_for :users, controllers: {
    # sessions: 'users/sessions'
    registrations: 'users/registrations'
  }

  # devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  namespace :my do
    root "ballots#index"
    resources :ballots do
      resources :questions
      resources :ballot_invitations do
        collection do
          post :bulk_create
        end
      end
    end
  end

  resources :ballots, only: [:show] do
    get "/invite/:token", to: "ballot_invitations#accept", as: :accept_invitation
    post :submit_votes
  end
end
