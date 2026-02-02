# frozen_string_literal: true

class JoinRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:create]

  # POST /trips/:trip_id/join_requests
  def create
    @join_request = @trip.join_requests.build(join_request_params)
    @join_request.user = current_user

    if @join_request.save
      render json: {
        status: "success",
        message: "Join request sent",
        data: { join_request: @join_request.as_json_response }
      }, status: :created
    else
      render json: {
        status: "error",
        message: "Join request failed",
        errors: @join_request.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_trip
    @trip = Trip.find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "error",
      message: "Trip not found"
    }, status: :not_found
  end

  def join_request_params
    params.require(:join_request).permit(:travel_type, :group_size, :starting_location)
  end
end
