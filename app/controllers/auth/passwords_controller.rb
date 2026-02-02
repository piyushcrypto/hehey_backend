# frozen_string_literal: true

module Auth
  class PasswordsController < ApplicationController
    before_action :authenticate_user!

    # PUT /auth/password
    def update
      # Map new_password to password for Devise compatibility
      mapped_params = {
        current_password: params.dig(:user, :current_password),
        password: params.dig(:user, :new_password),
        password_confirmation: params.dig(:user, :new_password)
      }

      if current_user.update_with_password(mapped_params)
        # Regenerate JTI to invalidate old tokens
        # This forces the user to login again with the new password
        current_user.update!(jti: SecureRandom.uuid)

        render json: {
          status: "success",
          message: "Password updated successfully"
        }, status: :ok
      else
        render json: {
          status: "error",
          message: "Password update failed",
          errors: current_user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end
