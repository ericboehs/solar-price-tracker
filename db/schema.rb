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

ActiveRecord::Schema[8.0].define(version: 2025_06_15_064806) do
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
    t.string "title", null: false
    t.string "url", null: false
    t.string "slug", null: false
    t.string "image_url"
    t.decimal "price", precision: 8, scale: 2
    t.datetime "last_scraped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "watches", force: :cascade do |t|
    t.string "url", null: false
    t.string "watch_type", default: "search", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.text "omit_terms"
    t.boolean "exclude_bundles", default: true, null: false
    t.datetime "last_scraped_at"
    t.integer "products_found", default: 0
    t.integer "scrape_count", default: 0
    t.datetime "next_scrape_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "next_scrape_at"], name: "index_watches_on_active_and_next_scrape_at"
    t.index ["active"], name: "index_watches_on_active"
    t.index ["last_scraped_at"], name: "index_watches_on_last_scraped_at"
    t.index ["next_scrape_at"], name: "index_watches_on_next_scrape_at"
    t.index ["watch_type"], name: "index_watches_on_watch_type"
  end

  add_foreign_key "price_histories", "products"
  add_foreign_key "sessions", "users"
end
