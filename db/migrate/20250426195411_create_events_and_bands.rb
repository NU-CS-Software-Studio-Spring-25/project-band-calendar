class CreateEventsAndBands < ActiveRecord::Migration[8.0]
  def change
    create_table 'events' do |t|
      t.string 'name'
      t.datetime 'date'
      t.string 'venue'
      t.string 'location'
    end

    create_table 'bands' do |t|
      t.string 'name'
      t.string 'photo_url'
      t.string 'bio'
    end
  end
end