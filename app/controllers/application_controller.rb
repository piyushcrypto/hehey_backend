# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rescue from common errors and return JSON responses
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email])
  end

  def not_found
    render json: {
      status: "error",
      message: "Resource not found"
    }, status: :not_found
  end

  def bad_request(exception)
    render json: {
      status: "error",
      message: exception.message
    }, status: :bad_request
  end

  # Authenticate user via JWT
  def authenticate_user!
    unless current_user
      render json: {
        status: "error",
        message: "Authentication required"
      }, status: :unauthorized
    end
  end

  # Get current user from warden/JWT
  def current_user
    @current_user ||= warden&.authenticate(scope: :user)
  end

  def warden
    request.env["warden"]
  end
end
