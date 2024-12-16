Rails.application.routes.draw do
  root "homepage#index"
  resources :categories
  resources :goals
  get '/auth/google_oauth2/callback', to: 'users/sessions#google_oauth2'  # Change action name if needed
  get '/auth/failure', to: 'users/sessions#auth_failure'

  resources :tasks do
    member do
      patch :complete  # Mark a task as complete
    end
  end
  
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  get "callback", to: "sessions#callback"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
