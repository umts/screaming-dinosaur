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

ActiveRecord::Schema[7.2].define(version: 2025_06_03_145306) do
  create_table "assignments", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.integer "user_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "roster_id"
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.integer "roster_id"
    t.integer "user_id"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "roster_id"], name: "index_memberships_on_user_id_and_roster_id", unique: true
  end

  create_table "rosters", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "fallback_user_id"
    t.integer "switchover", default: 1020, null: false
    t.string "phone"
    t.string "slug"
    t.index ["name"], name: "index_rosters_on_name", unique: true
    t.index ["slug"], name: "index_rosters_on_slug", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
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
    t.string "shibboleth_eppn"
    t.index ["calendar_access_token"], name: "index_users_on_calendar_access_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["spire"], name: "index_users_on_spire", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.datetime "created_at", precision: nil
    t.text "object", size: :long, collation: "utf8mb4_bin"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.check_constraint "json_valid(`object`)", name: "object"
  end
end
