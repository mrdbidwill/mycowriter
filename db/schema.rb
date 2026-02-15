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

ActiveRecord::Schema[8.0].define(version: 2026_02_15_220708) do
  create_table "books", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mb_lists", charset: "utf8mb4", collation: "utf8mb4_0900_as_cs", force: :cascade do |t|
    t.text "mblist_id"
    t.text "taxon_name"
    t.text "authors"
    t.text "rank_name"
    t.text "year_of_effective_publication"
    t.text "name_status"
    t.text "mycobank_number"
    t.text "hyperlink"
    t.text "classification"
    t.text "current_name"
    t.text "synonymy"
    t.index ["name_status"], name: "index_mblists_on_name_status", length: 255
    t.index ["rank_name"], name: "index_mblists_on_rank_name", length: 255
    t.index ["taxon_name", "rank_name"], name: "index_mblists_on_taxon_name_and_rank_name", length: 255
    t.index ["taxon_name"], name: "index_mblists_on_taxon_name", length: 255
  end

  create_table "paragraphs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.text "content"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_paragraphs_on_section_id"
  end

  create_table "sections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "title"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_sections_on_book_id"
  end

  add_foreign_key "paragraphs", "sections"
  add_foreign_key "sections", "books"
end
