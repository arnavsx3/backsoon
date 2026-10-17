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

ActiveRecord::Schema[8.1].define(version: 2026_10_17_171951) do
  create_table "borrowers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "email"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "user_id"], name: "index_borrowers_on_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_borrowers_on_user_id"
    t.check_constraint "length(trim(name)) BETWEEN 1 AND 80", name: "borrowers_name_length"
  end

  create_table "items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "user_id"], name: "index_items_on_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_items_on_user_id"
    t.check_constraint "length(trim(name)) BETWEEN 1 AND 80", name: "items_name_length"
  end

  create_table "loans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.bigint "item_id", null: false
    t.bigint "borrower_id", null: false
    t.date "lent_on", null: false
    t.date "due_on", null: false
    t.date "returned_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrower_id"], name: "index_loans_on_borrower_id"
    t.index ["item_id"], name: "one_outstanding_loan_per_item", unique: true, where: "returned_on IS NULL"
    t.index ["user_id", "due_on"], name: "index_loans_on_user_id_and_due_on"
    t.index ["user_id"], name: "index_loans_on_user_id"
    t.check_constraint "due_on >= lent_on", name: "loan_due_after_lending"
    t.check_constraint "returned_on IS NULL OR returned_on >= lent_on", name: "loan_return_after_lending"
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
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "borrowers", "users"
  add_foreign_key "items", "users"
  add_foreign_key "loans", "borrowers", column: ["borrower_id", "user_id"], primary_key: ["id", "user_id"]
  add_foreign_key "loans", "items", column: ["item_id", "user_id"], primary_key: ["id", "user_id"]
  add_foreign_key "loans", "users"
  add_foreign_key "sessions", "users"
end
