# frozen_string_literal: true

module Api
  module V1
    # Base controller for all API v1 controllers
    # Includes authentication by default
    class BaseController < ApplicationController
      include Authenticatable
    end
  end
end
