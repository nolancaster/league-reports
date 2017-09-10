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

ActiveRecord::Schema.define(version: 20170910055513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer "season"
    t.integer "week"
    t.integer "type"
    t.bigint "away_id"
    t.bigint "home_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_id"], name: "index_games_on_away_id"
    t.index ["home_id"], name: "index_games_on_home_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.integer "founded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lineups", force: :cascade do |t|
    t.float "score"
    t.integer "result"
    t.string "team_name"
    t.bigint "team_id"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_lineups_on_owner_id"
    t.index ["team_id"], name: "index_lineups_on_team_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_owners_on_league_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "league_id"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_teams_on_league_id"
    t.index ["owner_id"], name: "index_teams_on_owner_id"
  end

  add_foreign_key "lineups", "owners"
  add_foreign_key "lineups", "teams"
  add_foreign_key "owners", "leagues"
  add_foreign_key "teams", "leagues"
  add_foreign_key "teams", "owners"
end
