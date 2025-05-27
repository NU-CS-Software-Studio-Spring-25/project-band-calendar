class AddVenueToEvents < ActiveRecord::Migration[8.0]
  def up
    # 1. Add venue_id column initially as nullable
    add_reference :events, :venue, null: true, foreign_key: true
    
    # 2. Create a default venue if none exists
    default_venue_id = execute("SELECT id FROM venues ORDER BY id LIMIT 1").first
    
    if default_venue_id.nil?
      say_with_time "Creating a default venue" do
        default_venue_id = execute("INSERT INTO venues (name, city, country, created_at, updated_at) VALUES ('Default Venue', 'Unknown', 'Unknown', NOW(), NOW()) RETURNING id").first['id']
      end
    else
      default_venue_id = default_venue_id['id']
    end
    
    # 3. Update all existing records to use the default venue
    say_with_time "Setting default venue for existing events" do
      execute("UPDATE events SET venue_id = #{default_venue_id} WHERE venue_id IS NULL")
    end
    
    # 4. Now add the non-null constraint
    change_column_null :events, :venue_id, false
  end
  
  def down
    remove_reference :events, :venue
  end
end
