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

ActiveRecord::Schema[8.1].define(version: 2026_02_23_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.boolean "notify_on_generate", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.string "modulo", null: false
    t.integer "object_id"
    t.string "rotulo", null: false
    t.datetime "updated_at", null: false
    t.string "valor"
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["modulo"], name: "index_events_on_modulo"
    t.index ["object_id"], name: "index_events_on_object_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "streams", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.string "error_message"
    t.integer "frames_count", default: 0, null: false
    t.datetime "last_error_at"
    t.datetime "last_frame_at"
    t.string "name", null: false
    t.string "preview_url"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["client_id"], name: "index_streams_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.integer "duration"
    t.string "file_path"
    t.datetime "generated_at"
    t.text "note"
    t.string "share_link"
    t.bigint "stream_id", null: false
    t.string "thumbnail_url"
    t.datetime "updated_at", null: false
    t.index ["stream_id"], name: "index_videos_on_stream_id"
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "streams", "clients"
  add_foreign_key "videos", "streams"
end
