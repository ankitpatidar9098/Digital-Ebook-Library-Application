Rails.application.routes.draw do
  namespace :api do
    # Search must come before :id routes to avoid being captured as an ID
    get "ebooks/search", to: "ebooks#search"

    resources :ebooks, only: [:index, :show, :create, :destroy] do
      member do
        get  :download
        patch :read_position
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
