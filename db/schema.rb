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

ActiveRecord::Schema[8.1].define(version: 2026_08_24_234932) do
  create_table "domain_statuses", force: :cascade do |t|
    t.datetime "checked_at"
    t.datetime "created_at", null: false
    t.integer "domain_id", null: false
    t.boolean "is_online"
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_domain_statuses_on_domain_id"
  end

  create_table "domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "nic_id"
    t.date "registration_date"
    t.string "transaction_type"
    t.datetime "updated_at", null: false
    t.string "zone"
    t.index ["nic_id"], name: "index_domains_on_nic_id", unique: true
    t.index ["registration_date"], name: "index_domains_on_registration_date"
  end

  add_foreign_key "domain_statuses", "domains"
end
