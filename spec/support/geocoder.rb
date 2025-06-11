# Configure Geocoder for test environment
Geocoder.configure(
  # Disable HTTP requests in test environment
  lookup: :test,
  # Set timeout to avoid slow tests
  timeout: 1,
  # Use test lookup for faster tests
  always_raise: :all
)

# Set up test geocoding data for consistent test results
Geocoder::Lookup::Test.add_stub(
  "New York, NY, USA", [
    {
      'latitude'     => 40.7128,
      'longitude'    => -74.0060,
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "Los Angeles, CA, USA", [
    {
      'latitude'     => 34.0522,
      'longitude'    => -118.2437,
      'address'      => 'Los Angeles, CA, USA',
      'state'        => 'California',
      'state_code'   => 'CA',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

# Set up default stub for other addresses
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => 40.7128,
      'longitude'    => -74.0060,
      'address'      => 'Default Test Address',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
) 