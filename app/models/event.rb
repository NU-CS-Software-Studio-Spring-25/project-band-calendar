class Event < ApplicationRecord
  belongs_to :venue
  belongs_to :submitted_by, class_name: "User", optional: true
  has_many :band_events, dependent: :destroy
  has_many :bands, through: :band_events
  delegate :latitude, :longitude, to: :venue
  validates :name, :date, presence: true
  validates :name, uniqueness: { scope: :date, message: "already exists for this date" }
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  
  def pending?
    !approved?
  end
  
  def self.near_location(lat, lon, radius_in_miles = 10)
    joins(:venue).merge(Venue.near([lat, lon], radius_in_miles))
  end
  
end