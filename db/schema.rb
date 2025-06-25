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

ActiveRecord::Schema[8.0].define(version: 2025_06_23_033045) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "event_type", null: false
    t.jsonb "event_data", null: false
    t.datetime "occurred_at", null: false
    t.integer "version", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_number", null: false
    t.index ["game_number", "version"], name: "index_events_on_game_number_and_version", unique: true
    t.index ["game_number"], name: "index_events_on_game_number"
  end

  create_table "histories", force: :cascade do |t|
    t.jsonb "hand_set"
    t.integer "rank"
    t.datetime "ended_at"
    t.integer "last_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_number", null: false
    t.index ["ended_at"], name: "index_histories_on_ended_at"
    t.index ["game_number"], name: "index_histories_on_game_number"
  end

  create_table "player_hand_states", force: :cascade do |t|
    t.jsonb "hand_set", null: false
    t.string "current_rank", null: false
    t.integer "current_turn", null: false
    t.integer "status", null: false
    t.integer "last_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_number", null: false
    t.index ["game_number"], name: "index_player_hand_states_on_game_number"
    t.index ["game_number"], name: "index_player_hand_states_on_game_number_unique", unique: true
  end

  create_table "projection_versions", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "projection_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_number", null: false
    t.index ["game_number"], name: "index_projection_versions_on_game_number"
  end

  create_table "trash_states", force: :cascade do |t|
    t.jsonb "discarded_cards", null: false
    t.integer "current_turn", null: false
    t.integer "last_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_number", null: false
    t.index ["game_number"], name: "index_trash_states_on_game_number"
  end
end
