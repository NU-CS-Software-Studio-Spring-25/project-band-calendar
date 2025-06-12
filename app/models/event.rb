# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  date           :date             not null
#  approved       :boolean          default(false)
#  venue_id       :bigint           not null
#  submitted_by_id:bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Represents a music event at a given venue.
#
# Events can include many bands and are submitted by users (optionally).
class Event < ApplicationRecord
  # Associations
  belongs_to :venue
  belongs_to :submitted_by, class_name: "User", optional: true
  has_many :band_events, dependent: :destroy
  has_many :bands, through: :band_events

  # Delegate geolocation attributes from venue
  delegate :latitude, :longitude, to: :venue

  # Validations
  validates :name, :date, presence: true
  validates :name, uniqueness: { scope: :date, message: "already exists for this date" }
  validates :name, length: { maximum: 255 }

  # Scopes
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }

  # Checks if the event is pending approval.
  #
  # @return [Boolean] true if not approved, false otherwise
  def pending?
    !approved?
  end

  # Finds events near a specific latitude and longitude.
  #
  # @param lat [Float] latitude
  # @param lon [Float] longitude
  # @param radius_in_miles [Integer] search radius (default: 10 miles)
  # @return [ActiveRecord::Relation] events near the given location
  def self.near_location(lat, lon, radius_in_miles = 10)
    joins(:venue).merge(Venue.near([ lat, lon ], radius_in_miles))
  end
end
