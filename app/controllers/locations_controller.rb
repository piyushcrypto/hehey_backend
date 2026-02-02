# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :authenticate_user!

  # GET /locations/popular
  def popular
    destinations = Trip.popular_destinations(10)

    render json: {
      status: "success",
      data: { locations: destinations }
    }, status: :ok
  end
end
