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

ActiveRecord::Schema[8.1].define(version: 2026_02_25_193429) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
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

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "assignments", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "end_date"
    t.integer "roster_id"
    t.date "start_date"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
  end

  create_table "maintenance_tasks_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.text "arguments"
    t.text "backtrace"
    t.datetime "created_at", null: false
    t.string "cursor"
    t.datetime "ended_at"
    t.string "error_class"
    t.string "error_message"
    t.string "job_id"
    t.integer "lock_version", default: 0, null: false
    t.text "metadata"
    t.datetime "started_at"
    t.string "status", default: "enqueued", null: false
    t.string "task_name", null: false
    t.bigint "tick_count", default: 0, null: false
    t.bigint "tick_total"
    t.float "time_running", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["task_name", "status", "created_at"], name: "index_maintenance_tasks_runs", order: { created_at: :desc }
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "roster_id"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.index ["user_id", "roster_id"], name: "index_memberships_on_user_id_and_roster_id", unique: true
  end

  create_table "rosters", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "fallback_user_id"
    t.string "name"
    t.string "phone"
    t.string "slug"
    t.integer "switchover", default: 1020, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_rosters_on_name", unique: true
    t.index ["slug"], name: "index_rosters_on_slug", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.boolean "admin", default: false, null: false
    t.string "calendar_access_token"
    t.boolean "change_notifications_enabled", default: true
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "entra_uid", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.boolean "reminders_enabled", default: true
    t.string "shibboleth_eppn"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["calendar_access_token"], name: "index_users_on_calendar_access_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["entra_uid"], name: "index_users_on_entra_uid", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_520_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.text "object", size: :long, collation: "utf8mb4_bin"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.check_constraint "json_valid(`object`)", name: "object"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
