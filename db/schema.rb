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

ActiveRecord::Schema.define(version: 20161204134213) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "base_ingredients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ingredients", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "recipe_id"
    t.uuid     "base_ingredient_id"
    t.decimal  "amount"
    t.string   "amountUnit"
    t.string   "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["base_ingredient_id"], name: "index_ingredients_on_base_ingredient_id", using: :btree
    t.index ["recipe_id"], name: "index_ingredients_on_recipe_id", using: :btree
  end

  create_table "recipe_parses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.string   "imageURL"
    t.text     "ingredients"
    t.text     "directions"
    t.uuid     "recipe_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["recipe_id"], name: "index_recipe_parses_on_recipe_id", using: :btree
  end

  create_table "recipes", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "sourceURL"
    t.string   "imageURL"
    t.text     "directions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ingredients", "base_ingredients"
  add_foreign_key "ingredients", "recipes"
  add_foreign_key "recipe_parses", "recipes"
end
