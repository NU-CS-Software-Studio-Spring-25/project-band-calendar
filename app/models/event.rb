class Event < ApplicationRecord
  has_and_belongs_to_many :bands
  
  validates :name, :venue, :location, :date, presence: true
  validates :name, uniqueness: { scope: :date, message: "already exists for this date" }
end