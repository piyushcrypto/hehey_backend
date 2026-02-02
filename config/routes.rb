Rails.application.routes.draw do
  # Authentication routes
  scope :auth do
    devise_for :users,
               path: "",
               path_names: {
                 sign_in: "login",
                 sign_out: "logout",
                 registration: "register"
               },
               controllers: {
                 sessions: "auth/sessions",
                 registrations: "auth/registrations"
               },
               skip: [:passwords],
               defaults: { format: :json }

    # Custom password change endpoint (authenticated users changing their password)
    put "password", to: "auth/passwords#update"

    # Profile management
    get "profile", to: "auth/profiles#show"
    put "profile", to: "auth/profiles#update"
    put "profile/avatar", to: "auth/profiles#update_avatar"
    delete "profile/avatar", to: "auth/profiles#destroy_avatar"
  end

  # Home endpoint (single request for all home screen data)
  get "home", to: "home#index"

  # Trip routes
  resources :trips, only: [:create, :show, :update, :destroy] do
    collection do
      get :latest
      get :expiring_soon
      get :sponsored
      get :search
      get :my
      get :joined
    end
    member do
      patch :reschedule
    end
    resources :join_requests, only: [:create]
  end

  # Location routes
  resources :locations, only: [] do
    collection do
      get :popular
    end
  end

  # API routes (protected)
  namespace :api do
    namespace :v1 do
      resource :profile, only: [:show], controller: "profile"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
