class BandEvent < ApplicationRecord
  belongs_to :band
  belongs_to :event
  
  validates :band_id, uniqueness: { scope: :event_id }
  validates :set_position, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  
  scope :ordered_by_time, -> { order(:start_time) }
  scope :ordered_by_position, -> { order(:set_position) }
end 