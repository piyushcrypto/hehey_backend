# frozen_string_literal: true

# Devise configuration for API-only authentication with JWT

Devise.setup do |config|
  # ==> Security Configuration
  # Configure the number of stretches to use when hashing password
  config.stretches = Rails.env.test? ? 1 : 12

  # Send a notification to the original email when the user's email is changed
  config.send_email_changed_notification = true

  # Send a notification email when the user's password is changed
  config.send_password_change_notification = true

  # ==> Mailer Configuration
  config.mailer_sender = "noreply@example.com"

  # ==> ORM configuration
  require "devise/orm/active_record"

  # ==> Authentication Configuration
  # Configure authentication keys
  config.authentication_keys = [:email]

  # Case insensitive and strip whitespace for authentication keys
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # ==> Password Configuration
  # Minimum password length
  config.password_length = 8..128

  # Email regex for validations
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> API-only Configuration
  # Skip session storage for API-only apps
  config.skip_session_storage = [:http_auth, :params_auth]

  # ==> Navigation Configuration
  # Configure navigational formats (empty for API-only)
  config.navigational_formats = []

  # ==> JWT Configuration
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key || ENV.fetch("DEVISE_JWT_SECRET_KEY") { Rails.application.secret_key_base }
    jwt.dispatch_requests = [
      ["POST", %r{^/auth/login$}],
      ["POST", %r{^/auth/register$}]
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/auth/logout$}]
    ]
    jwt.expiration_time = 24.hours.to_i
  end

  # ==> Warden Configuration
  config.warden do |manager|
    manager.failure_app = DeviseCustomFailure
  end
end
