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

ActiveRecord::Schema[8.1].define(version: 2026_06_10_131052) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "meanings", comment: "Keeps the Meanings of corresponding Words", force: :cascade do |t|
    t.jsonb "anki_response", comment: "The Anki Response"
    t.datetime "created_at", null: false
    t.jsonb "parsed_meaning", comment: "The meaning of Word parsed from dictionary"
    t.text "status", null: false, comment: "Status of creating of Anki card"
    t.text "text", null: false, comment: "The Meaning itself"
    t.datetime "updated_at", null: false
    t.bigint "word_id", null: false, comment: "Belongs to Word"
    t.index ["word_id"], name: "index_meanings_on_word_id"
  end

  create_table "words", comment: "Keeps English Words", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "parsed_meanings", comment: "The meanings of Word parsed from dictionary"
    t.text "text", null: false, comment: "The Word itself"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "meanings", "words"
end
