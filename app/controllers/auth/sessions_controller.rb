# frozen_string_literal: true

module Auth
  class SessionsController < Devise::SessionsController
    respond_to :json

    # Skip verify_signed_out_user since we don't use sessions
    skip_before_action :verify_signed_out_user, only: [:destroy]

    # Override create to avoid session storage issues
    def create
      self.resource = warden.authenticate!(auth_options)

      # Generate JWT token
      token = generate_jwt_token(resource)

      render json: {
        status: "success",
        message: "Logged in successfully",
        data: {
          user: user_data(resource),
          token: token
        }
      }, status: :ok
    end

    def destroy
      # Get the current user from JWT before destroying
      user = current_user

      if user
        # Revoke the JWT by regenerating the JTI
        user.update!(jti: SecureRandom.uuid)

        render json: {
          status: "success",
          message: "Logged out successfully"
        }, status: :ok
      else
        render json: {
          status: "error",
          message: "No active session"
        }, status: :unauthorized
      end
    end

    private

    def user_data(user)
      {
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        full_name: user.full_name,
        phone: user.phone,
        country_code: user.country_code,
        full_phone: user.full_phone
      }
    end

    def generate_jwt_token(user)
      Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    end
  end
end
