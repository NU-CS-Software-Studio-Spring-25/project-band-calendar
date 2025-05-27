class Band < ApplicationRecord
  has_many :band_events, dependent: :destroy
  has_many :events, through: :band_events
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end