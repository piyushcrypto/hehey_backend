# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  # GET /home
  # Returns all data needed for the home screen in a single request
  def index
    render json: {
      status: "success",
      data: {
        latest_trips: latest_trips,
        expiring_soon_trips: expiring_soon_trips,
        sponsored_trips: sponsored_trips,
        popular_locations: popular_locations
      }
    }, status: :ok
  end

  private

  def base_query
    Trip.active.includes(:user, image_attachment: :blob, user: { avatar_attachment: :blob })
  end

  def latest_trips
    base_query.not_expired.latest.limit(10).map(&:as_json_card)
  end

  def expiring_soon_trips
    base_query.expiring_soon.limit(10).map(&:as_json_card)
  end

  def sponsored_trips
    base_query.not_expired.sponsored.latest.limit(10).map(&:as_json_card)
  end

  def popular_locations
    Trip.active.not_expired.popular_destinations(10)
  end
end
