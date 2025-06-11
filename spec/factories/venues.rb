FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Venue #{n}" }
    street_address { "123 Main Street" }
    city { "New York" }
    state { "NY" }
    postal_code { "10001" }
    country { "USA" }
    description { "A great venue for live music" }
    venue_type { "Concert Hall" }
    capacity { 500 }
    website { "https://venue.example.com" }
    phone { "555-123-4567" }
    email { "info@venue.example.com" }
    accessible { true }
    all_ages { true }
    has_food { false }
    has_bar { true }
    
    # Skip geocoding in tests since latitude/longitude columns don't exist yet
    after(:build) do |venue|
      venue.define_singleton_method(:geocode) { true }
    end
  end
end 