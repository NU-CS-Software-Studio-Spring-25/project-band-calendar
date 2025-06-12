# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_10_212906) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_notifications", force: :cascade do |t|
    t.text "subject"
    t.text "content"
    t.text "event_ids"
    t.text "user_ids"
    t.bigint "sent_by_id", null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sent_by_id"], name: "index_admin_notifications_on_sent_by_id"
  end

  create_table "band_events", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "band_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "set_position"
    t.text "notes"
    t.index ["band_id", "event_id"], name: "index_band_events_on_band_id_and_event_id", unique: true
    t.index ["band_id"], name: "index_band_events_on_band_id"
    t.index ["event_id"], name: "index_band_events_on_event_id"
  end

  create_table "bands", force: :cascade do |t|
    t.string "name"
    t.string "photo_url"
    t.string "bio"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.string "venue"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "venue_id"
    t.boolean "approved", default: false
    t.bigint "submitted_by_id"
    t.index ["submitted_by_id"], name: "index_events_on_submitted_by_id"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.string "street_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city", default: "Unknown", null: false
    t.string "state"
    t.string "postal_code"
    t.string "country", default: "Unknown", null: false
    t.text "description"
    t.string "venue_type"
    t.integer "capacity"
    t.string "website"
    t.string "phone"
    t.string "email"
    t.boolean "accessible", default: false
    t.boolean "all_ages", default: false
    t.boolean "has_food", default: false
    t.boolean "has_bar", default: false
    t.float "latitude"
    t.float "longitude"
<<<<<<< HEAD
    t.index ["latitude", "longitude"], name: "index_venues_on_latitude_and_longitude"
=======
>>>>>>> 86cf4eea2abdaea33153d5580f2b079fa0df8031
    t.index ["name"], name: "index_venues_on_name", unique: true
  end

  add_foreign_key "admin_notifications", "users", column: "sent_by_id"
  add_foreign_key "band_events", "bands"
  add_foreign_key "band_events", "events"
  add_foreign_key "events", "users", column: "submitted_by_id"
  add_foreign_key "events", "venues"
end
