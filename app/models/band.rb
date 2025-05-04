class Band < ApplicationRecord
  has_and_belongs_to_many :events
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end