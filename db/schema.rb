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

ActiveRecord::Schema[7.2].define(version: 2025_03_19_141414) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ballot_invitations", force: :cascade do |t|
    t.bigint "ballot_id", null: false
    t.string "email"
    t.string "token", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ballot_membership_id"
    t.index ["ballot_id"], name: "index_ballot_invitations_on_ballot_id"
    t.index ["ballot_membership_id"], name: "index_ballot_invitations_on_ballot_membership_id"
    t.index ["email", "accepted_at"], name: "index_ballot_invitations_on_email_and_accepted_at", where: "(accepted_at IS NULL)"
    t.index ["token"], name: "index_ballot_invitations_on_token", unique: true
  end

  create_table "ballot_memberships", force: :cascade do |t|
    t.bigint "ballot_id", null: false
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ballot_id", "profile_id"], name: "index_ballot_memberships_on_ballot_id_and_profile_id", unique: true
    t.index ["ballot_id"], name: "index_ballot_memberships_on_ballot_id"
    t.index ["profile_id"], name: "index_ballot_memberships_on_profile_id"
  end

  create_table "ballot_options", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.bigint "ballot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ballot_id"], name: "index_ballot_options_on_ballot_id"
  end

  create_table "ballots", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "ends_at"
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: false
    t.string "slug", null: false
    t.index ["profile_id"], name: "index_ballots_on_profile_id"
    t.index ["slug"], name: "index_ballots_on_slug", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.string "handle"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handle"], name: "index_profiles_on_handle", unique: true, where: "(handle IS NOT NULL)"
  end

  create_table "tmp_votes", force: :cascade do |t|
    t.bigint "ballot_id", null: false
    t.string "email", null: false
    t.json "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.string "token", null: false
    t.index ["token"], name: "index_tmp_votes_on_token", unique: true
  end

  create_table "user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_user_profiles_on_profile_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "main_profile_id", null: false
    t.string "remember_token", limit: 20
    t.string "provider"
    t.string "uid"
    t.boolean "beta", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["main_profile_id"], name: "index_users_on_main_profile_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "ballot_id", null: false
    t.bigint "profile_id"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending", default: false
    t.string "pending_email"
    t.string "pending_token"
    t.index ["ballot_id"], name: "index_votes_on_ballot_id"
    t.index ["pending_token"], name: "index_votes_on_pending_token", unique: true
    t.index ["profile_id"], name: "index_votes_on_profile_id"
  end

  add_foreign_key "ballot_invitations", "ballot_memberships"
  add_foreign_key "ballot_invitations", "ballots"
  add_foreign_key "ballot_memberships", "ballots"
  add_foreign_key "ballot_memberships", "profiles"
  add_foreign_key "ballot_options", "ballots"
  add_foreign_key "ballots", "profiles"
  add_foreign_key "user_profiles", "profiles"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "users", "profiles", column: "main_profile_id"
  add_foreign_key "votes", "ballots"
  add_foreign_key "votes", "profiles"
end
