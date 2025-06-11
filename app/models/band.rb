# == Schema Information
#
# Table name: bands
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  photo_url  :string
#  bio        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Represents a musical band that can perform at multiple events.
#
# A band may have many scheduled performances (band_events) and be associated with many events.
class Band < ApplicationRecord
  # Associations
  has_many :band_events, dependent: :destroy
  has_many :events, through: :band_events

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
