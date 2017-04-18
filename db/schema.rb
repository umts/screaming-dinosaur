# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170418165938) do

  create_table "assignments", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "roster_id",  limit: 4
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "roster_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "admin",                default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "rosters", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "fallback_user_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "spire",             limit: 255
    t.string   "email",             limit: 255
    t.string   "phone",             limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "reminders_enabled",             default: true
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 191,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
