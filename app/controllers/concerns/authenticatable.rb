# frozen_string_literal: true

# Concern to provide JWT authentication for protected controllers
#
# Usage:
#   class Api::V1::ProtectedController < ApplicationController
#     include Authenticatable
#
#     def index
#       render json: { user: current_user }
#     end
#   end
#
# This concern automatically adds a before_action to authenticate the user.
# For controllers that need authentication only on specific actions, use:
#
#   class Api::V1::MixedController < ApplicationController
#     include Authenticatable
#     skip_before_action :authenticate_user!, only: [:public_action]
#   end
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end
end
