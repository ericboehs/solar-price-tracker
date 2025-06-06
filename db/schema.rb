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

ActiveRecord::Schema[8.0].define(version: 2025_06_06_201842) do
  create_table "price_histories", force: :cascade do |t|
    t.integer "product_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "recorded_at"], name: "index_price_histories_on_product_id_and_recorded_at"
    t.index ["product_id"], name: "index_price_histories_on_product_id"
    t.index ["recorded_at"], name: "index_price_histories_on_recorded_at"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.decimal "price"
    t.string "image_url"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "price_histories", "products"
end
