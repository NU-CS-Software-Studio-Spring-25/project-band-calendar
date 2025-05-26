class Event < ApplicationRecord
  belongs_to :venue
  has_many :band_events, dependent: :destroy
  has_many :bands, through: :band_events
  
  validates :name, :location, :date, presence: true
  validates :name, uniqueness: { scope: :date, message: "already exists for this date" }
end