class FixAddVenueToEvents < ActiveRecord::Migration[8.0]
  def up
    # Step 1: Check if venue_id column exists already
    unless column_exists?(:events, :venue_id)
      # Step 2: Add venue_id column as nullable
      add_reference :events, :venue, null: true, foreign_key: true
    end

    # Step 3: Create a default venue if none exist
    default_venue = execute("SELECT id FROM venues LIMIT 1").first
    
    if default_venue.nil?
      say_with_time "Creating a default venue" do
        default_venue_id = execute("INSERT INTO venues (name, city, country, created_at, updated_at) VALUES ('Default Venue', 'Unknown', 'Unknown', NOW(), NOW()) RETURNING id").first["id"]
      end
    else
      default_venue_id = default_venue["id"]
    end
    
    # Step 4: Update all existing records with NULL venue_id
    say_with_time "Setting venue_id for existing events" do
      execute("UPDATE events SET venue_id = #{default_venue_id} WHERE venue_id IS NULL")
    end
    
    # Step 5: Now change the column to not null after data is migrated
    say_with_time "Adding NOT NULL constraint to venue_id" do
      change_column_null :events, :venue_id, false
    end
  end

  def down
    # Make venue_id nullable again
    change_column_null :events, :venue_id, true
  end
end 