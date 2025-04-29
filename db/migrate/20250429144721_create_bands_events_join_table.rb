class CreateBandsEventsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table 'bands_events', id: false do |t|
      t.belongs_to :event
      t.belongs_to :band
    end
    
    # Also add timestamps that were missing
    add_column :bands, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :bands, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :events, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :events, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end