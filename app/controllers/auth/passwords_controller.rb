# frozen_string_literal: true

module Auth
  class PasswordsController < ApplicationController
    before_action :authenticate_user!

    # PUT /auth/password
    def update
      if current_user.update_with_password(password_params)
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

    private

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
  end
end
