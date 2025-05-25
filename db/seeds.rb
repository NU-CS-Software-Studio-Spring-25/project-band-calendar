# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'
require 'set'

# Clear existing data
puts "Clearing existing data..."
Band.destroy_all
Event.destroy_all

# Create a few sample events without bands (optional)
puts "Creating sample events..."
5.times do |i|
  Event.create!(
    name: "Sample Event #{i + 1}",
    date: Faker::Time.between(from: DateTime.now, to: 2.months.from_now),
    venue: "Sample Venue #{i + 1}",
    location: "Sample City, Sample State"
  )
end

puts "Seed data created successfully!"