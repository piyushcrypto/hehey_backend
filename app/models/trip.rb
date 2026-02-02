# frozen_string_literal: true

class Trip < ApplicationRecord
  # Constants
  STATUSES = %w[active cancelled completed].freeze
  PREFERRED_BUDDY_TYPES = %w[male female any].freeze
  TRANSPORT_MODES = %w[own_car public_transport].freeze
  ACCOMMODATION_TYPES = %w[hostels budget_hotels premium_stays].freeze
  SPLITTING_TYPES = %w[equal go_dutch].freeze

  # Associations
  belongs_to :user
  has_many :join_requests, dependent: :destroy
  has_one_attached :image

  # Virtual attribute for using profile picture
  attr_accessor :use_profile_picture

  # Callbacks
  before_validation :derive_has_car_from_transport_mode

  # Validations
  validates :destination, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :max_people, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_people, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :itinerary, presence: true
  validates :preferred_buddy_type, presence: true, inclusion: { in: PREFERRED_BUDDY_TYPES }
  validates :budget, presence: true
  validates :transport_mode, presence: true, inclusion: { in: TRANSPORT_MODES }
  validates :accommodation_type, presence: true, inclusion: { in: ACCOMMODATION_TYPES }
  validates :splitting_type, presence: true, inclusion: { in: SPLITTING_TYPES }

  validate :end_date_after_start_date
  validate :current_people_not_exceeding_max, unless: :is_solo_traveler?

  # Scopes
  scope :latest, -> { order(created_at: :desc) }
  scope :sponsored, -> { where(sponsored: true) }
  scope :with_car, -> { where(has_car: true) }
  scope :open_for_joining, -> { where(open_for_joining: true) }
  scope :solo, -> { where(is_solo_traveler: true) }
  scope :group_trips, -> { where(is_solo_traveler: false) }
  # A trip is "expiring soon" if start_date is within the next 3 days
  scope :expiring_soon, -> { where(start_date: Date.current..3.days.from_now.to_date).order(start_date: :asc) }
  # A trip is visible only if start_date hasn't passed yet
  scope :not_expired, -> { where("start_date >= ?", Date.current) }
  # Alias for clarity
  scope :upcoming, -> { where("start_date >= ?", Date.current) }
  scope :active, -> { where(status: "active") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :completed, -> { where(status: "completed") }
  scope :by_status, ->(status) { status.present? ? where(status: status) : all }

  # Search/filter scope
  scope :filter_by, ->(filters) {
    result = all
    result = result.where("destination ILIKE ?", "%#{filters[:destination]}%") if filters[:destination].present?
    result = result.where(sponsored: true) if filters[:sponsored].to_s == "true"
    result = result.where(has_car: true) if filters[:has_car].to_s == "true"
    result = result.where(open_for_joining: true) if filters[:open_for_joining].to_s == "true"
    result = result.where(is_solo_traveler: true) if filters[:is_solo_traveler].to_s == "true"
    result = result.where(is_solo_traveler: false) if filters[:is_solo_traveler].to_s == "false"
    result = result.where("max_people >= ?", filters[:max_people].to_i) if filters[:max_people].present? && filters[:is_solo_traveler].to_s != "true"
    result
  }

  # Class methods
  def self.popular_destinations(limit = 10)
    group(:destination)
      .order("count_all DESC")
      .limit(limit)
      .count
      .map { |destination, count| { destination: destination, trip_count: count } }
  end

  # Instance methods
  def expiring_soon?
    start_date.present? && start_date <= 3.days.from_now.to_date && start_date >= Date.current
  end

  def expired?
    start_date.present? && start_date < Date.current
  end

  def spots_available
    return 0 if is_solo_traveler?
    max_people - current_people
  end

  def full?
    return true if is_solo_traveler?
    current_people >= max_people
  end

  def active?
    status == "active"
  end

  def cancelled?
    status == "cancelled"
  end

  def cancel!
    update_column(:status, "cancelled")
  end

  # Returns the appropriate image URL
  # Priority: 1. Uploaded trip image, 2. Legacy image_url field, 3. Creator's avatar
  def display_image_url
    if image.attached?
      build_s3_url(image.blob.key)
    elsif image_url.present?
      image_url
    elsif user&.avatar&.attached?
      user.avatar_url
    else
      nil
    end
  end

  def build_s3_url(key)
    return nil if key.blank?
    region = ENV.fetch("AWS_REGION", "ap-south-1")
    bucket = ENV.fetch("AWS_BUCKET", "hehey-bucket")
    "https://#{bucket}.s3.#{region}.amazonaws.com/#{key}"
  end

  # JSON representation for API
  def as_json_card
    {
      id: id,
      image_url: display_image_url,
      destination: destination,
      itinerary: itinerary,
      preferred_buddy_type: preferred_buddy_type,
      description: description,
      budget: budget,
      splitting_type: splitting_type,
      transport_mode: transport_mode,
      accommodation_type: accommodation_type,
      start_date: start_date,
      end_date: end_date,
      is_solo_traveler: is_solo_traveler,
      sponsored: sponsored,
      has_car: has_car,
      open_for_joining: open_for_joining,
      max_people: max_people,
      current_people: current_people,
      spots_available: spots_available,
      status: status,
      creator: user.as_json_creator,
      created_at: created_at
    }
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def current_people_not_exceeding_max
    return unless current_people.present? && max_people.present?

    if current_people > max_people
      errors.add(:current_people, "cannot exceed max people")
    end
  end

  def derive_has_car_from_transport_mode
    self.has_car = (transport_mode == "own_car")
  end

  def default_url_host
    Rails.env.production? ? "https://your-production-domain.com" : "http://localhost:3000"
  end
end
