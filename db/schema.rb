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

ActiveRecord::Schema.define(version: 2024_04_25_105712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "expenses", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "paid_at", null: false
    t.string "description", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_expenses_on_creator_id"
  end

  create_table "journal_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "transaction_type", null: false
    t.datetime "paid_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_journal_transactions_on_account_id"
    t.index ["user_id", "account_id", "source_id", "source_type"], name: "index_jt_user_account_source", unique: true
    t.index ["user_id", "paid_at", "transaction_type"], name: "index_jt_user_time_type"
    t.index ["user_id", "paid_at"], name: "index_jt_user_time"
    t.index ["user_id"], name: "index_journal_transactions_on_user_id"
  end

  create_table "payment_components", force: :cascade do |t|
    t.bigint "expense_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "description", null: false
    t.integer "category", null: false
    t.integer "split", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expense_id"], name: "index_payment_components_on_expense_id"
  end

  create_table "settlements", force: :cascade do |t|
    t.bigint "payer_id", null: false
    t.bigint "payee_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "paid_at", null: false
    t.text "notes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payee_id"], name: "index_settlements_on_payee_id"
    t.index ["payer_id"], name: "index_settlements_on_payer_id"
  end

  create_table "split_payments", force: :cascade do |t|
    t.bigint "payment_component_id", null: false
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "category", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_component_id"], name: "index_split_payments_on_payment_component_id"
    t.index ["user_id"], name: "index_split_payments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "mobile_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "expenses", "users", column: "creator_id"
  add_foreign_key "journal_transactions", "users"
  add_foreign_key "journal_transactions", "users", column: "account_id"
  add_foreign_key "payment_components", "expenses"
  add_foreign_key "settlements", "users", column: "payee_id"
  add_foreign_key "settlements", "users", column: "payer_id"
  add_foreign_key "split_payments", "payment_components"
  add_foreign_key "split_payments", "users"
end
