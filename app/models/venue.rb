class Venue < ApplicationRecord
  has_many :events, dependent: :nullify
  
  validates :name, presence: true, uniqueness: true
  validates :city, :country, presence: true
  geocoded_by :full_address
  after_validation :geocode
  
  def full_address
    [street_address, city, state, postal_code, country].compact.join(", ")
  end
  
  def display_name
    "#{name}, #{city}"
  end
end
