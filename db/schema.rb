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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150728134349) do

  create_table "applicaties", :force => true do |t|
    t.boolean  "rapportperiode"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "dags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fouts", :force => true do |t|
    t.string   "name"
    t.integer  "proef_id"
    t.integer  "position"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "foutwijzings", :force => true do |t|
    t.integer  "resultaat_id"
    t.integer  "fout_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "groeps", :force => true do |t|
    t.integer  "lesgever_id"
    t.integer  "lesuur_id"
    t.integer  "niveau_id"
    t.boolean  "done_vlag"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "klas", :force => true do |t|
    t.string   "name"
    t.integer  "school_id"
    t.integer  "lesuur_id"
    t.boolean  "tweeweek"
    t.boolean  "nietdilbeeks"
    t.integer  "week",         :default => 0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.boolean  "verborgen"
  end

  create_table "lesgevers", :force => true do |t|
    t.string   "name"
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "lesgevers", ["email"], :name => "index_lesgevers_on_email", :unique => true
  add_index "lesgevers", ["reset_password_token"], :name => "index_lesgevers_on_reset_password_token", :unique => true

  create_table "lesgevers_roles", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "lesgever_id"
  end

  create_table "lesuurs", :force => true do |t|
    t.string   "name"
    t.integer  "dag_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "nieuws", :force => true do |t|
    t.string   "soort"
    t.string   "datum"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "niveaus", :force => true do |t|
    t.string   "name"
    t.string   "kleurcode"
    t.integer  "position"
    t.string   "karakter"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "opmerkings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "overgangs", :force => true do |t|
    t.integer  "zwemmer_id"
    t.string   "van"
    t.string   "naar"
    t.string   "lesgever"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "kleurcode_van"
    t.string   "kleurcode_naar"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.text     "niveaus"
    t.text     "totals"
    t.text     "details"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "schools"
    t.text     "klas"
    t.text     "proefs"
    t.text     "fouts"
  end

  create_table "proefs", :force => true do |t|
    t.integer  "niveau_id"
    t.string   "scoretype"
    t.boolean  "belangrijk"
    t.string   "content"
    t.integer  "position"
    t.boolean  "nietdilbeeks"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "quoterings", :force => true do |t|
    t.integer  "proef_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rapports", :force => true do |t|
    t.integer  "zwemmer_id"
    t.string   "lesgever"
    t.string   "niveau"
    t.string   "standaard_extra"
    t.text     "extra"
    t.boolean  "klaar"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "overvlag"
    t.string   "school"
    t.string   "klas"
    t.string   "niveaus"
    t.string   "kleurcode"
  end

  create_table "resultaats", :force => true do |t|
    t.string   "name"
    t.integer  "rapport_id"
    t.string   "score"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "proef_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tijds", :force => true do |t|
    t.integer  "aantal"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "zwemmers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "extra"
    t.integer  "kla_id"
    t.integer  "groep_id"
    t.boolean  "overvlag"
    t.boolean  "netovervlag"
    t.integer  "groepvlag",   :default => 0
    t.boolean  "importvlag"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "badmuts"
    t.boolean  "nieuw"
  end

end
