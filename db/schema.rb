# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_14_003900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "address_line"
    t.string "street_name"
    t.string "street_number"
    t.string "comment"
    t.string "zip_code"
    t.string "city_name"
    t.string "state_name"
    t.string "country_id"
    t.string "country_name"
    t.string "neighborhood"
    t.string "neighborhood_name"
    t.float "latitude"
    t.float "longitude"
    t.string "receiver_phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
