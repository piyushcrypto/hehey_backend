# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, uniqueness: true, allow_blank: true
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }, allow_blank: true

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

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end
