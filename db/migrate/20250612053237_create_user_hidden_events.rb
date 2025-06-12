class CreateUserHiddenEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_hidden_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    # 防止重复 hide 同一个 event
    add_index :user_hidden_events, [:user_id, :event_id], unique: true
  end
end
