# frozen_string_literal: true

class TripImageUploadJob < ApplicationJob
  queue_as :default

  # Receives raw file data and uploads to S3 in background
  def perform(trip_id, file_data, filename, content_type)
    trip = Trip.find_by(id: trip_id)
    return unless trip

    # Create a temp file from the binary data
    temp_file = Tempfile.new([filename, File.extname(filename)])
    temp_file.binmode
    temp_file.write(file_data)
    temp_file.rewind

    # Attach to Active Storage (this uploads to S3)
    trip.image.attach(
      io: temp_file,
      filename: filename,
      content_type: content_type
    )

    Rails.logger.info "[TripImageUploadJob] Successfully uploaded image for Trip##{trip_id}"
  rescue StandardError => e
    Rails.logger.error "[TripImageUploadJob] Failed to upload image for Trip##{trip_id}: #{e.message}"
    raise e # Re-raise to mark job as failed for retry
  ensure
    temp_file&.close
    temp_file&.unlink
  end
end
