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

ActiveRecord::Schema[8.1].define(version: 2026_02_02_012200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "join_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_size", default: 1, null: false
    t.string "starting_location", null: false
    t.string "status", default: "pending", null: false
    t.string "travel_type", null: false
    t.bigint "trip_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_join_requests_on_status"
    t.index ["travel_type"], name: "index_join_requests_on_travel_type"
    t.index ["trip_id", "user_id"], name: "index_join_requests_on_trip_id_and_user_id", unique: true
    t.index ["trip_id"], name: "index_join_requests_on_trip_id"
    t.index ["user_id"], name: "index_join_requests_on_user_id"
  end

  create_table "trips", force: :cascade do |t|
    t.string "accommodation_type"
    t.string "budget"
    t.datetime "created_at", null: false
    t.integer "current_people", default: 1, null: false
    t.text "description", null: false
    t.string "destination", null: false
    t.date "end_date", null: false
    t.boolean "has_car", default: false, null: false
    t.string "image_url"
    t.boolean "is_solo_traveler", default: false, null: false
    t.text "itinerary"
    t.integer "max_people", default: 1, null: false
    t.boolean "open_for_joining", default: true, null: false
    t.string "preferred_buddy_type"
    t.string "splitting_type", default: "equal", null: false
    t.boolean "sponsored", default: false, null: false
    t.date "start_date", null: false
    t.string "status", default: "active", null: false
    t.string "transport_mode"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["accommodation_type"], name: "index_trips_on_accommodation_type"
    t.index ["created_at"], name: "index_trips_on_created_at"
    t.index ["destination"], name: "index_trips_on_destination"
    t.index ["is_solo_traveler"], name: "index_trips_on_is_solo_traveler"
    t.index ["preferred_buddy_type"], name: "index_trips_on_preferred_buddy_type"
    t.index ["splitting_type"], name: "index_trips_on_splitting_type"
    t.index ["sponsored"], name: "index_trips_on_sponsored"
    t.index ["status"], name: "index_trips_on_status"
    t.index ["transport_mode"], name: "index_trips_on_transport_mode"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "city"
    t.string "country_code", default: "+91"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "gender"
    t.string "jti", null: false
    t.string "last_name", default: "", null: false
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "work_profile"
    t.index ["city"], name: "index_users_on_city"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gender"], name: "index_users_on_gender"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true, where: "((phone IS NOT NULL) AND ((phone)::text <> ''::text))"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "join_requests", "trips"
  add_foreign_key "join_requests", "users"
  add_foreign_key "trips", "users"
end
