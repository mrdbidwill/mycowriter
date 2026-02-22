Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Demo and documentation pages
  get "demo", to: "pages#demo"
  get "docs", to: "pages#gem_docs"

  # Autocomplete endpoints for demo functionality
  get "autocomplete/taxa", to: "autocomplete#taxa"
  get "autocomplete/genera", to: "autocomplete#genera", as: :genera_autocomplete
  get "autocomplete/species", to: "autocomplete#species", as: :species_autocomplete

  # Root redirects to demo
  root "pages#demo"
end
