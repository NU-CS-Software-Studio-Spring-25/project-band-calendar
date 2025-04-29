class Event < ApplicationRecord
  has_and_belongs_to_many :bands
end