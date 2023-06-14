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

ActiveRecord::Schema[7.0].define(version: 2021_02_18_203357) do
  create_table "assignments", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "roster_id"
  end

  create_table "memberships", charset: "utf8mb4", force: :cascade do |t|
    t.integer "roster_id"
    t.integer "user_id"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "roster_id"], name: "index_memberships_on_user_id_and_roster_id", unique: true
  end

  create_table "rosters", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "fallback_user_id"
    t.index ["name"], name: "index_rosters_on_name", unique: true
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "spire"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "reminders_enabled", default: true
    t.boolean "change_notifications_enabled", default: true
    t.boolean "active", default: true
    t.string "calendar_access_token"
    t.index ["calendar_access_token"], name: "index_users_on_calendar_access_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["spire"], name: "index_users_on_spire", unique: true
  end

  create_table "versions", charset: "utf8mb4", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at", precision: nil
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
