# frozen_string_literal: true

module Auth
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    # Override create to skip automatic sign-in which tries to use sessions
    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?

      if resource.persisted?
        # Generate JWT token for the new user
        token = generate_jwt_token(resource)

        render json: {
          status: "success",
          message: "Signed up successfully",
          data: {
            user: user_data(resource),
            token: token
          }
        }, status: :created
      else
        clean_up_passwords resource
        set_minimum_password_length
        render json: {
          status: "error",
          message: "Sign up failed",
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    private

    def sign_up_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :phone,
        :country_code,
        :password,
        :password_confirmation
      )
    end

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
