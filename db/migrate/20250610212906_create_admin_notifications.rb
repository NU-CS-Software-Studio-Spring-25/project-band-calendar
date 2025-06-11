class CreateAdminNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_notifications do |t|
      t.text :subject
      t.text :content
      t.text :event_ids
      t.text :user_ids
      t.references :sent_by, null: false, foreign_key: { to_table: :users }
      t.datetime :sent_at

      t.timestamps
    end
  end
end
