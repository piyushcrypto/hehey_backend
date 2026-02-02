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
