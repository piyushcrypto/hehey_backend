# frozen_string_literal: true

module Auth
  class ProfilesController < ApplicationController
    before_action :authenticate_user!

    # GET /auth/profile
    def show
      render json: {
        status: "success",
        data: { user: current_user.as_json_profile }
      }, status: :ok
    end

    # PUT /auth/profile
    def update
      if current_user.update(profile_params)
        render json: {
          status: "success",
          data: { user: current_user.as_json_profile }
        }, status: :ok
      else
        render json: {
          status: "error",
          message: "Profile update failed",
          errors: current_user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # PUT /auth/profile/avatar
    def update_avatar
      avatar_file = params.dig(:user, :avatar)

      unless avatar_file.present?
        return render json: {
          status: "error",
          message: "Avatar file is required"
        }, status: :unprocessable_entity
      end

      # Purge old avatar if exists
      current_user.avatar.purge if current_user.avatar.attached?

      # Read file data and enqueue for background upload to S3
      file_data = avatar_file.read
      filename = avatar_file.original_filename
      content_type = avatar_file.content_type

      AvatarUploadJob.perform_later(current_user.id, file_data, filename, content_type)

      render json: {
        status: "success",
        message: "Avatar upload queued successfully",
        data: { user: current_user.as_json_profile }
      }, status: :ok
    end

    # DELETE /auth/profile/avatar
    def destroy_avatar
      if current_user.avatar.attached?
        current_user.avatar.purge
        render json: {
          status: "success",
          data: { user: current_user.as_json_profile }
        }, status: :ok
      else
        render json: {
          status: "error",
          message: "No avatar to remove"
        }, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:user).permit(:first_name, :last_name, :phone, :country_code, :gender, :date_of_birth, :city, :work_profile)
    end
  end
end
