# frozen_string_literal: true

class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show, :update, :destroy, :reschedule]

  PER_PAGE = 10

  # POST /trips
  def create
    # Extract image before building trip (we'll handle it separately)
    image_file = params.dig(:trip, :image)
    trip_attributes = trip_params.except(:image)

    @trip = current_user.trips.build(trip_attributes)

    # Handle use_profile_picture option
    if use_profile_picture?
      # Don't attach any image - display_image_url will fall back to creator's avatar
      @trip.image_url = nil
    end

    if @trip.save
      # Enqueue image upload as background job if image provided
      if image_file.present? && !use_profile_picture?
        enqueue_trip_image_upload(@trip.id, image_file)
      end

      # Reload to ensure all associations are loaded
      @trip.reload
      render json: {
        status: "success",
        message: "Trip created successfully",
        data: { trip: @trip.as_json_card }
      }, status: :created
    else
      render json: {
        status: "error",
        message: "Trip creation failed",
        errors: @trip.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /trips/:id
  def show
    render json: {
      status: "success",
      data: { trip: @trip.as_json_card }
    }, status: :ok
  end

  # PATCH/PUT /trips/:id
  def update
    unless @trip.user_id == current_user.id
      return render json: {
        status: "error",
        message: "Not authorized to update this trip"
      }, status: :forbidden
    end

    unless @trip.active?
      return render json: {
        status: "error",
        message: "Cannot edit a #{@trip.status} trip"
      }, status: :unprocessable_entity
    end

    # Extract image before updating (we'll handle it separately)
    image_file = params.dig(:trip, :image)
    update_attributes = trip_params.except(:image)

    # Handle use_profile_picture option on update
    if use_profile_picture?
      @trip.image.purge if @trip.image.attached?
      @trip.image_url = nil
    end

    if @trip.update(update_attributes)
      # Enqueue image upload as background job if image provided
      if image_file.present? && !use_profile_picture?
        @trip.image.purge if @trip.image.attached? # Remove old image
        enqueue_trip_image_upload(@trip.id, image_file)
      end

      render json: {
        status: "success",
        message: "Trip updated successfully",
        data: { trip: @trip.as_json_card }
      }, status: :ok
    else
      render json: {
        status: "error",
        message: "Trip update failed",
        errors: @trip.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /trips/:id - Soft delete (cancel trip)
  def destroy
    unless @trip.user_id == current_user.id
      return render json: {
        status: "error",
        message: "Not authorized to cancel this trip"
      }, status: :forbidden
    end

    @trip.cancel!
    render json: {
      status: "success",
      message: "Trip cancelled successfully"
    }, status: :ok
  end

  # PATCH /trips/:id/reschedule
  def reschedule
    unless @trip.user_id == current_user.id
      return render json: {
        status: "error",
        message: "Not authorized to reschedule this trip"
      }, status: :forbidden
    end

    unless @trip.active?
      return render json: {
        status: "error",
        message: "Cannot reschedule a #{@trip.status} trip"
      }, status: :unprocessable_entity
    end

    if @trip.update(reschedule_params)
      render json: {
        status: "success",
        message: "Trip rescheduled successfully",
        data: { trip: @trip.as_json_card }
      }, status: :ok
    else
      render json: {
        status: "error",
        message: "Trip reschedule failed",
        errors: @trip.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /trips/latest?page=1
  def latest
    trips = base_query.not_expired.latest
    render_paginated(trips)
  end

  # GET /trips/expiring_soon?page=1
  def expiring_soon
    trips = base_query.expiring_soon
    render_paginated(trips)
  end

  # GET /trips/sponsored?page=1
  def sponsored
    trips = base_query.not_expired.sponsored.latest
    render_paginated(trips)
  end

  # GET /trips/search?page=1&destination=&sponsored=&has_car=&open_for_joining=&max_people=
  def search
    trips = base_query.not_expired.filter_by(search_params).latest
    render_paginated(trips)
  end

  # GET /trips/my?page=1&status=active
  def my
    trips = current_user.trips
                        .includes(image_attachment: :blob, user: { avatar_attachment: :blob })
                        .by_status(params[:status])
                        .latest
    render_paginated(trips)
  end

  # GET /trips/joined?page=1
  def joined
    trip_ids = current_user.join_requests.approved.pluck(:trip_id)
    trips = Trip.where(id: trip_ids)
                .includes(:user, image_attachment: :blob, user: { avatar_attachment: :blob })
                .latest
    render_paginated(trips)
  end

  private

  def base_query
    Trip.active.includes(:user, image_attachment: :blob, user: { avatar_attachment: :blob })
  end

  def render_paginated(trips)
    page = [params[:page].to_i, 1].max
    total_count = trips.count
    total_pages = (total_count.to_f / PER_PAGE).ceil
    offset = (page - 1) * PER_PAGE

    paginated_trips = trips.offset(offset).limit(PER_PAGE)

    render json: {
      status: "success",
      data: {
        trips: paginated_trips.map(&:as_json_card),
        pagination: {
          current_page: page,
          total_pages: total_pages,
          total_count: total_count,
          per_page: PER_PAGE,
          has_next: page < total_pages,
          has_prev: page > 1
        }
      }
    }, status: :ok
  end

  def set_trip
    @trip = Trip.includes(:user, image_attachment: :blob, user: { avatar_attachment: :blob })
                .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      status: "error",
      message: "Trip not found"
    }, status: :not_found
  end

  def trip_params
    params.require(:trip).permit(
      :destination,
      :itinerary,
      :preferred_buddy_type,
      :description,
      :budget,
      :splitting_type,
      :transport_mode,
      :accommodation_type,
      :start_date,
      :end_date,
      :image,
      :image_url,
      :max_people,
      :current_people,
      :is_solo_traveler,
      :sponsored,
      :open_for_joining
    )
  end

  def search_params
    permitted = params.permit(:destination, :location, :sponsored, :has_car, :open_for_joining, :max_people, :is_solo_traveler)
    # Accept both 'location' and 'destination' for flexibility
    permitted[:destination] ||= permitted[:location]
    permitted
  end

  def reschedule_params
    params.require(:trip).permit(:start_date, :end_date)
  end

  def use_profile_picture?
    params.dig(:trip, :use_profile_picture).to_s == "true"
  end

  def enqueue_trip_image_upload(trip_id, image_file)
    # Read file data into memory and enqueue for background processing
    file_data = image_file.read
    filename = image_file.original_filename
    content_type = image_file.content_type

    TripImageUploadJob.perform_later(trip_id, file_data, filename, content_type)
  end
end
