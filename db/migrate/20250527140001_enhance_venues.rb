class EnhanceVenues < ActiveRecord::Migration[8.0]
  def change
    change_table :venues do |t|
      # Rename address to street_address
      t.rename :address, :street_address

      # Add new fields
      t.string :city, null: false, default: 'Unknown'
      t.string :state
      t.string :postal_code
      t.string :country, null: false, default: 'Unknown'
      t.text :description
      t.string :venue_type
      t.integer :capacity
      t.string :website
      t.string :phone
      t.string :email
      t.boolean :accessible, default: false
      t.boolean :all_ages, default: false
      t.boolean :has_food, default: false
      t.boolean :has_bar, default: false
    end

    # Add uniqueness constraint to name
    add_index :venues, :name, unique: true, if_not_exists: true

    # Make name not null
    change_column_null :venues, :name, false
  end
end 