# frozen_string_literal: true

# Configure AWS SDK to handle SSL certificate issues
# This disables CRL (Certificate Revocation List) checking which can fail on some systems

require "aws-sdk-s3"

if Rails.env.development?
  # Workaround for macOS SSL certificate CRL verification issues
  Aws.config.update(
    http_open_timeout: 5,
    http_read_timeout: 10,
    ssl_verify_peer: false
  )
else
  Aws.config.update(
    http_open_timeout: 5,
    http_read_timeout: 10,
    ssl_verify_peer: true
  )
end
