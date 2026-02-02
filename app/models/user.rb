# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Constants
  GENDERS = %w[male female other].freeze

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Associations
  has_many :trips, dependent: :destroy
  has_many :join_requests, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, uniqueness: true, allow_blank: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }, allow_blank: true
  validates :gender, presence: true, inclusion: { in: GENDERS }, allow_nil: true
  validates :work_profile, presence: true, allow_nil: true
  validates :date_of_birth, presence: true, allow_nil: true

  # Generate a new JTI on creation
  before_create :generate_jti

  # Returns full name
  def full_name
    "#{first_name} #{last_name}".strip
  end

  # Returns phone with country code
  def full_phone
    return nil if phone.blank?
    "#{country_code}#{phone}"
  end

  # Calculate age from date of birth
  def age
    return nil unless date_of_birth.present?
    now = Time.current.to_date
    age = now.year - date_of_birth.year
    age -= 1 if now < date_of_birth + age.years
    age
  end

  # Returns avatar URL or nil
  def avatar_url
    return nil unless avatar.attached?
    build_s3_url(avatar.blob.key)
  end

  def build_s3_url(key)
    return nil if key.blank?
    region = ENV.fetch("AWS_REGION", "ap-south-1")
    bucket = ENV.fetch("AWS_BUCKET", "hehey-bucket")
    "https://#{bucket}.s3.#{region}.amazonaws.com/#{key}"
  end

  # JSON representation for profile API
  def as_json_profile
    {
      id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      phone: phone,
      country_code: country_code,
      full_phone: full_phone,
      avatar_url: avatar_url,
      gender: gender,
      date_of_birth: date_of_birth&.iso8601,
      city: city,
      work_profile: work_profile
    }
  end

  # JSON representation for trip creator
  def as_json_creator
    {
      id: id,
      name: full_name,
      first_name: first_name,
      last_name: last_name,
      avatar_url: avatar_url,
      gender: gender,
      work_profile: work_profile,
      age: age
    }
  end

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def default_url_host
    Rails.env.production? ? "https://your-production-domain.com" : "http://localhost:3000"
  end
end
