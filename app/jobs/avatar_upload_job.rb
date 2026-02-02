# frozen_string_literal: true

class AvatarUploadJob < ApplicationJob
  queue_as :default

  # Receives raw file data and uploads to S3 in background
  def perform(user_id, file_data, filename, content_type)
    user = User.find_by(id: user_id)
    return unless user

    # Create a temp file from the binary data
    temp_file = Tempfile.new([filename, File.extname(filename)])
    temp_file.binmode
    temp_file.write(file_data)
    temp_file.rewind

    # Attach to Active Storage (this uploads to S3)
    user.avatar.attach(
      io: temp_file,
      filename: filename,
      content_type: content_type
    )

    Rails.logger.info "[AvatarUploadJob] Successfully uploaded avatar for User##{user_id}"
  rescue StandardError => e
    Rails.logger.error "[AvatarUploadJob] Failed to upload avatar for User##{user_id}: #{e.message}"
    raise e # Re-raise to mark job as failed for retry
  ensure
    temp_file&.close
    temp_file&.unlink
  end
end
