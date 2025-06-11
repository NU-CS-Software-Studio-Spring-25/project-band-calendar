# config/initializers/geocoder.rb
Geocoder.configure(
  timeout: 10,                 # Default is 3 seconds
  units: :mi,                 # Or :km
  lookup: :nominatim,         # or :google if you have an API key
  use_https: true,
  http_headers: {
    "User-Agent" => "software-studio-app (software-studio-d7d9fa70f610.herokuapp.com)"
  }
)
