Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # Dashboard
  get 'dashboard', to: 'dashboard#index'

  # Ballots
  resources :ballots do
    resources :options, only: [:new, :create, :edit, :update, :destroy]
    member do
      post 'vote'
      get 'results'
    end
  end

  # Catch-all route for ballot links
  get 'b/:id', to: 'ballots#show', as: 'ballot_link'
end
