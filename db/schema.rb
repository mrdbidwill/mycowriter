# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running
# `bin/rails db:schema:load`. If you use `db:test:prepare`, Rails will load
# this schema for the test database.

ActiveRecord::Schema[8.0].define(version: 2026_02_27_000000) do
  create_table "api_keys", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "name", null: false
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "api_keys", [ "token" ], unique: true
  add_index "api_keys", [ "user_id" ]

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

  create_table "articles", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "articles", [ "user_id" ]

  create_table "paragraphs", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.text "content"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "paragraphs", [ "section_id" ]

  create_table "sections", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.string "title"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sections", [ "article_id" ]

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", [ "email" ], unique: true
  add_index "users", [ "reset_password_token" ], unique: true

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
