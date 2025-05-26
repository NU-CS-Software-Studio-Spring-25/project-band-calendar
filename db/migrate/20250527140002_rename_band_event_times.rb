class RenameBandEventTimes < ActiveRecord::Migration[8.0]
  def change
    # Rename the table
    rename_table :band_event_times, :band_events

    # Add the missing columns
    add_column :band_events, :set_position, :integer
    add_column :band_events, :notes, :text
    
    # Add a unique index on band_id and event_id
    add_index :band_events, [:band_id, :event_id], unique: true, if_not_exists: true
  end
end 