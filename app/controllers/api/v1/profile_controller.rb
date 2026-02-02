# frozen_string_literal: true

module Api
  module V1
    # Example protected controller
    # Demonstrates how to use authentication in API endpoints
    class ProfileController < BaseController
      # GET /api/v1/profile
      def show
        render json: {
          status: "success",
          data: {
            user: {
              id: current_user.id,
              email: current_user.email,
              created_at: current_user.created_at
            }
          }
        }, status: :ok
      end
    end
  end
end
