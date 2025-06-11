namespace :venues do
    desc "Geocode all venues missing coordinates"
    task geocode_missing: :environment do
      Venue.where(latitude: nil).find_each do |venue|
        puts "Geocoding #{venue.name}..."
        sleep(1.1)
        venue.geocode
        if venue.latitude.present?
          puts " #{venue.name}: (#{venue.latitude}, #{venue.longitude})"
        else
          puts " FAILED: #{venue.name}"
        end
        venue.save(validate: false)
      end
    end
  end
  