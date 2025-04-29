# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

dillo_day = Event.create(
  name: 'Dillo Day', 
  date: '2025-06-17', 
  venue: 'Northwestern Lakefill', 
  location: 'Evanston, IL'
)

lollapalooza = Event.create(
  name: 'Lollapalooza', 
  date: '2025-08-01', 
  venue: 'Grant Park', 
  location: 'Chicago, IL'
)

# Create Bands
modest_mouse = Band.create(
  name: 'Modest Mouse',
  photo_url: 'https://example.com/modest_mouse.jpg',
  bio: 'American rock band formed in 1992'
)

kendrick = Band.create(
  name: 'Kendrick Lamar',
  photo_url: 'https://example.com/kendrick.jpg',
  bio: 'American rapper and songwriter'
)

tame_impala = Band.create(
  name: 'Tame Impala',
  photo_url: 'https://example.com/tame_impala.jpg',
  bio: 'Australian psychedelic music project'
)

# Associate bands with events
dillo_day.bands << modest_mouse
dillo_day.bands << tame_impala

lollapalooza.bands << kendrick
lollapalooza.bands << tame_impala