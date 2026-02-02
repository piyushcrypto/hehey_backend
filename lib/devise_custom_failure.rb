# frozen_string_literal: true

# Custom failure app for Devise to return JSON responses
class DeviseCustomFailure < Devise::FailureApp
  def respond
    json_error_response
  end

  def json_error_response
    self.status = 401
    self.content_type = "application/json"
    self.response_body = { error: i18n_message }.to_json
  end

  def i18n_message
    message = super
    message.presence || "Authentication required"
  end
end
