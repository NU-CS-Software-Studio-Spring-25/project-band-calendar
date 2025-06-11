# == Schema Information
#
# Table name: band_events
#
#  id           :bigint           not null, primary key
#  band_id      :bigint           not null
#  event_id     :bigint           not null
#  start_time   :datetime
#  end_time     :datetime
#  set_position :integer
#  notes        :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Join model representing a band's scheduled performance at an event.
#
# Each BandEvent links a Band to an Event, and includes optional details
# such as performance start/end time and set position.
class BandEvent < ApplicationRecord
  # Associations
  belongs_to :band
  belongs_to :event

  # Validations
  # Ensures that the same band cannot be added to the same event more than once.
  validates :band_id, uniqueness: { scope: :event_id }

  # Ensures set_position is a positive integer if provided.
  validates :set_position, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # Scopes
  # Orders band performances by start time
  scope :ordered_by_time, -> { order(:start_time) }

  # Orders band performances by set position
  scope :ordered_by_position, -> { order(:set_position) }
end
