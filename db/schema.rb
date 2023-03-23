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

ActiveRecord::Schema[7.0].define(version: 2023_03_10_204639) do
  create_table "drivers", force: :cascade do |t|
    t.string "name_on_system"
    t.string "truck"
    t.string "current_status"
    t.string "cycle_remainind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ninox_id"
    t.string "samsara_id"
  end

  create_table "samsaras", force: :cascade do |t|
    t.string "truck"
    t.decimal "odo_miles"
    t.date "date"
    t.string "gps_location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "truck"
    t.decimal "sub_total"
    t.date "post_data"
    t.date "event_data"
    t.string "time_post_data"
    t.string "time_event_data"
    t.string "product_name"
    t.string "product_qty"
    t.decimal "product_cost"
    t.string "loves_station"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trucks", force: :cascade do |t|
    t.string "name"
    t.string "samsara_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
