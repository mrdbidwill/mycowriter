# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running
# `bin/rails db:schema:load`. If you use `db:test:prepare`, Rails will load
# this schema for the test database.

ActiveRecord::Schema[8.0].define(version: 2026_03_14_000001) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "action_text_rich_texts", [ "record_type", "record_id", "name" ],
    unique: true,
    name: "index_action_text_rich_texts_uniqueness"

  create_table "ar_internal_metadata", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ar_internal_metadata", [ "key" ], unique: true

  create_table "schema_migrations", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  add_index "schema_migrations", [ "version" ], unique: true
end
