# frozen_string_literal: true

class JoinRequest < ApplicationRecord
  # Constants
  TRAVEL_TYPES = %w[solo group].freeze
  STATUSES = %w[pending approved rejected].freeze

  # Associations
  belongs_to :trip
  belongs_to :user

  # Validations
  validates :travel_type, presence: true, inclusion: { in: TRAVEL_TYPES }
  validates :group_size, presence: true, numericality: { greater_than: 0 }
  validates :starting_location, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :trip_id, message: "has already requested to join this trip" }

  validate :cannot_join_own_trip
  validate :trip_must_be_active

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  # Instance methods
  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end

  def approve!
    update_column(:status, "approved")
  end

  def reject!
    update_column(:status, "rejected")
  end

  # JSON representation for API
  def as_json_response
    {
      id: id,
      trip_id: trip_id,
      user_id: user_id,
      travel_type: travel_type,
      group_size: group_size,
      starting_location: starting_location,
      status: status,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def cannot_join_own_trip
    return unless trip.present? && user.present?

    if trip.user_id == user_id
      errors.add(:base, "You cannot join your own trip")
    end
  end

  def trip_must_be_active
    return unless trip.present?

    unless trip.active?
      errors.add(:base, "Cannot join a #{trip.status} trip")
    end
  end
end
