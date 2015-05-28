# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150522213910) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "title"
  end

  create_table "correspondences", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.integer  "no_read_ids",         default: [],              array: true
    t.integer  "position_id"
    t.integer  "offer_id"
    t.string   "correspondence_type"
    t.integer  "offerer_id"
    t.string   "status"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "correspondences", ["correspondence_type"], name: "index_correspondences_on_correspondence_type", using: :btree
  add_index "correspondences", ["offer_id"], name: "index_correspondences_on_offer_id", using: :btree
  add_index "correspondences", ["offerer_id"], name: "index_correspondences_on_offerer_id", using: :btree
  add_index "correspondences", ["position_id"], name: "index_correspondences_on_position_id", using: :btree
  add_index "correspondences", ["recipient_id"], name: "index_correspondences_on_recipient_id", using: :btree
  add_index "correspondences", ["sender_id"], name: "index_correspondences_on_sender_id", using: :btree

  create_table "correspondences_positions", force: :cascade do |t|
    t.integer "position_id"
    t.integer "correspondence_id"
  end

  create_table "correspondences_users", force: :cascade do |t|
    t.integer "correspondence_id"
    t.integer "user_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "document"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "file_name"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "body"
    t.integer  "correspondence_id"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "message_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "messages", ["correspondence_id"], name: "index_messages_on_correspondence_id", using: :btree

  create_table "options", force: :cascade do |t|
    t.string  "title"
    t.integer "category_id"
  end

  add_index "options", ["category_id"], name: "index_options_on_category_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.string   "photo"
    t.integer  "position_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "positions", force: :cascade do |t|
    t.boolean  "delta",               default: true,  null: false
    t.string   "status"
    t.integer  "position_id"
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "option_id"
    t.string   "template"
    t.integer  "trade_type"
    t.integer  "currency_id"
    t.float    "price"
    t.float    "price_etalon"
    t.float    "price_discount",      default: 0.0,   null: false
    t.float    "weight"
    t.float    "weight_min",          default: 0.0,   null: false
    t.float    "weight_etalon"
    t.float    "weight_min_etalon",   default: 0.0,   null: false
    t.integer  "weight_dimension_id"
    t.integer  "deal_with_id"
    t.boolean  "is_offer",            default: false, null: false
    t.string   "index_field"
    t.string   "city"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["city"], name: "index_positions_on_city", using: :btree
  add_index "positions", ["deal_with_id"], name: "index_positions_on_deal_with_id", using: :btree
  add_index "positions", ["is_offer"], name: "index_positions_on_is_offer", using: :btree
  add_index "positions", ["option_id"], name: "index_positions_on_option_id", using: :btree
  add_index "positions", ["position_id"], name: "index_positions_on_position_id", using: :btree
  add_index "positions", ["price_etalon"], name: "index_positions_on_price_etalon", using: :btree
  add_index "positions", ["trade_type"], name: "index_positions_on_trade_type", using: :btree
  add_index "positions", ["user_id"], name: "index_positions_on_user_id", using: :btree
  add_index "positions", ["weight_dimension_id"], name: "index_positions_on_weight_dimension_id", using: :btree
  add_index "positions", ["weight_etalon"], name: "index_positions_on_weight_etalon", using: :btree
  add_index "positions", ["weight_min_etalon"], name: "index_positions_on_weight_min_etalon", using: :btree

  create_table "positions_positions", force: :cascade do |t|
    t.integer "position_id"
    t.integer "incoming_offer_id"
    t.integer "outcoming_position_id"
  end

  create_table "positions_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "position_id"
    t.integer "favorite_id"
  end

  create_table "reputations", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "position_id"
    t.integer  "user_id"
    t.integer  "sender_id"
    t.string   "reputation_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "reputations", ["position_id"], name: "index_reputations_on_position_id", using: :btree
  add_index "reputations", ["sender_id"], name: "index_reputations_on_sender_id", using: :btree
  add_index "reputations", ["user_id"], name: "index_reputations_on_user_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "template_name"
    t.string   "title"
    t.text     "description"
    t.integer  "option_id"
    t.integer  "trade_type"
    t.float    "price"
    t.float    "price_discount"
    t.float    "weight"
    t.float    "weight_min"
    t.integer  "weight_dimension_id"
    t.integer  "currency_id"
    t.string   "city"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "templates", ["user_id"], name: "index_templates_on_user_id", using: :btree

  create_table "unread_messages", force: :cascade do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.integer  "correspondence_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name"
    t.string   "avatar"
    t.string   "phone",                  default: [],                 array: true
    t.string   "city"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.integer  "currency_id",            default: 2,     null: false
    t.string   "company"
    t.text     "additional"
    t.json     "cache",                  default: {}
    t.integer  "new_offers_count",       default: 0,     null: false
    t.string   "locale",                 default: "en",  null: false
    t.boolean  "email_notify",           default: true
    t.boolean  "sms_notify",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "connection_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "weight_dimensions", force: :cascade do |t|
    t.string   "name"
    t.float    "convert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "messages", "correspondences"
end
