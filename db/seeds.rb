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

# Create 50 bands
puts "Creating bands..."
used_band_names = Set.new

50.times do
  begin
    band_name = Faker::Music.band
    # Keep trying until we get a unique name
    while used_band_names.include?(band_name)
      band_name = Faker::Music.band
    end
    used_band_names.add(band_name)
    
    Band.create!(
      name: band_name,
      photo_url: Faker::Internet.url(host: 'example.com', path: '/band-photos'),
      bio: Faker::Lorem.paragraph(sentence_count: 3)
    )
  rescue ActiveRecord::RecordInvalid => e
    puts "Error creating band: #{e.message}"
    retry
  end
end

# Create 50 events
puts "Creating events..."
50.times do
  Event.create!(
    name: Faker::Music::RockBand.name + " Concert",
    date: Faker::Time.between(from: DateTime.now, to: 1.year.from_now),
    venue: Faker::Company.name + " Arena",
    location: Faker::Address.city + ", " + Faker::Address.state
  )
end

# Create random band-event associations
puts "Creating band-event associations..."
Event.all.each do |event|
  # Each event will have 1-4 bands
  rand(1..4).times do
    band = Band.all.sample
    event.bands << band unless event.bands.include?(band)
  end
end

puts "Seed data created successfully!"