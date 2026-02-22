Rails.application.routes.draw do
  get "pages/contact"
  get "pages/terms_of_service"
  get "docs", to: "pages#gem_docs"
  get "demo", to: "pages#demo"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Glossary routes
  get "glossary/definition", to: "glossary#definition"
  get "glossary", to: "glossary#index"

  # Articles (main editing interface)
  resources :articles do
    resources :sections, only: [ :create, :update, :destroy ] do
      member do
        patch :move_up
        patch :move_down
      end
      resources :paragraphs, only: [ :create, :update, :destroy ] do
        member do
          patch :move_up
          patch :move_down
        end
      end
    end
  end

  # Autocomplete endpoints for mb_lists
  get "autocomplete/taxa", to: "autocomplete#taxa"
  get "autocomplete/genera", to: "autocomplete#genera", as: :genera_autocomplete
  get "autocomplete/species", to: "autocomplete#species", as: :species_autocomplete

  # API key management
  resources :api_keys, only: [ :index, :create, :destroy ]

  # API Documentation
  get "api/docs", to: "api_docs#index", as: :api_docs

  # Public API v1 endpoints
  namespace :api do
    namespace :v1 do
      # Autocomplete endpoint for fungal taxa
      get "autocomplete/taxa", to: "autocomplete#taxa"

      # Glossary endpoints
      get "glossary/definition", to: "glossary#definition"
      get "glossary/terms", to: "glossary#terms"
    end
  end

  # Defines the root path route ("/")
  root "articles#index"
end
