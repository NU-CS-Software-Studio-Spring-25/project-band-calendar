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
BandEvent.destroy_all
Band.destroy_all
Event.destroy_all
Venue.destroy_all

# Create venues
puts "Creating venues..."
venue_types = ['Concert Hall', 'Bar', 'Club', 'Theater', 'Stadium', 'Outdoor', 'Other']
20.times do
  Venue.create!(
    name: "#{Faker::Restaurant.name} #{venue_types.sample}".strip,
    street_address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    postal_code: Faker::Address.zip_code,
    country: Faker::Address.country,
    description: Faker::Lorem.paragraphs(number: rand(1..3)).join("\n\n"),
    venue_type: venue_types.sample,
    capacity: rand(50..10000),
    website: Faker::Internet.url,
    phone: Faker::PhoneNumber.phone_number,
    email: Faker::Internet.email,
    accessible: [true, false].sample,
    all_ages: [true, false].sample,
    has_food: [true, false].sample,
    has_bar: [true, false].sample
  )
end

venues = Venue.all
puts "Created #{venues.count} venues"

# Create bands (note: in production these would likely come from Spotify)
puts "Creating bands..."
band_name_prefixes = ['The', 'DJ', 'MC', 'Electric', 'Savage', 'Wild', 'Crazy', 'Royal']
band_name_suffixes = ['Wolves', 'Dragons', 'Band', 'Orchestra', 'Crew', 'Collective', 'Experience', 'Project', 'Brothers']
30.times do
  # Creating realistic-sounding band names
  name_style = rand(3)
  band_name = case name_style
    when 0
      "#{band_name_prefixes.sample} #{Faker::Music.genre.split.first}"
    when 1
      "#{Faker::Color.color_name.capitalize} #{band_name_suffixes.sample}"
    else
      "#{Faker::Name.first_name} and the #{band_name_suffixes.sample}"
  end
  
  Band.create!(
    name: band_name,
    # In a real app, these would likely come from Spotify:
    photo_url: "https://placekitten.com/300/300?image=#{rand(1..16)}",
    bio: "#{Faker::Music.genre} band from #{Faker::Address.city}.\n\n#{Faker::Lorem.paragraph(sentence_count: 3)}"
  )
end

bands = Band.all
puts "Created #{bands.count} bands"

# Create events for the next two weeks
puts "Creating events for the next two weeks..."
today = Date.today
(0..14).each do |days_from_now|
  event_date = today + days_from_now.days
  # Create 2-5 events per day
  rand(2..5).times do
    # Randomize event time
    hour = rand(12..23)
    minute = [0, 30].sample
    event_datetime = event_date.to_datetime + hour.hours + minute.minutes
    
    event = Event.create!(
      name: "#{Faker::Marketing.buzzwords} #{['Night', 'Festival', 'Live', 'Concert', 'Show'].sample}",
      venue: venues.sample,
      location: Faker::Address.community,
      date: event_datetime
    )
    
    # Add 1-5 bands to each event (ensure no duplicate bands)
    event_bands = bands.to_a.shuffle.take(rand(1..5))
    event_bands.each_with_index do |band, i|
      start_time = event_datetime + (i * 45).minutes
      end_time = start_time + 45.minutes
      
      BandEvent.create!(
        event: event,
        band: band,
        set_position: i + 1,
        start_time: start_time,
        end_time: end_time,
        notes: rand < 0.3 ? Faker::Lorem.sentence : nil
      )
    end
  end
end

events = Event.all
band_events = BandEvent.all
puts "Created #{events.count} events with #{band_events.count} band performances"

# Create a special event for today
if Event.where("DATE(date) = ?", today).count == 0
  puts "Creating a guaranteed event for today..."
  today_venue = venues.sample
  today_event = Event.create!(
    name: "Tonight's Special Event",
    venue: today_venue,
    location: today_venue.city,
    date: today.to_datetime + 20.hours
  )
  
  # Ensure at least 3 bands for today's event (with no duplicates)
  today_bands = bands.to_a.shuffle.take(3)
  today_bands.each_with_index do |band, i|
    start_time = today_event.date + (i * 45).minutes
    end_time = start_time + 45.minutes
    
    BandEvent.create!(
      event: today_event,
      band: band,
      set_position: i + 1,
      start_time: start_time,
      end_time: end_time
    )
  end
end

puts "Seeding completed successfully!"