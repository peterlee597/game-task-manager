Rails.application.routes.draw do
  # Root route
  root "homepage#index"

  # Define custom routes
  resources :categories
  resources :goals

  # Tasks routes with a custom member route for completing tasks
  resources :tasks do
    member do
      patch :complete  # Mark a task as complete
    end
  end
  
  # Health check endpoint for uptime monitoring
  get "up" => "rails/health#show", as: :rails_health_check

  # Dynamic PWA files (service worker, manifest)
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Devise routes for users (session, registration, omniauth callbacks)
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks", # Custom controller for OmniAuth
    sessions: "users/sessions",                   # Custom session controller
    registrations: "users/registrations"          # Custom registration controller
  }

  # Custom route for handling OAuth callback within the Devise scope
  devise_scope :user do
    get '/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
    get '/auth/failure', to: 'users/omniauth_callbacks#failure'
  end

  # Other routes you may have:
  # get "callback", to: "sessions#callback"  # This is redundant, remove it
end