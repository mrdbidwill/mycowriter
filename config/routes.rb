Rails.application.routes.draw do
  mount Mycowriter::Engine => "/mycowriter"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Demo and documentation pages
  get "demo", to: "pages#demo"
  get "docs", to: "pages#gem_docs"
  get "privacy", to: "pages#privacy"
  post "privacy/opt_out", to: "pages#opt_out"
  post "privacy/opt_in", to: "pages#opt_in"

  # Root redirects to demo
  root "pages#demo"
end
