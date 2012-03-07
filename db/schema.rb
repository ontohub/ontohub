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

ActiveRecord::Schema.define(:version => 20120307143553) do

  create_table "logics", :force => true do |t|
    t.string   "name"
    t.string   "uri"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ontologies", :force => true do |t|
    t.integer  "logic_id"
    t.string   "uri"
    t.string   "state"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "ontologies", ["logic_id"], :name => "index_ontologies_on_logic_id"

  create_table "ontology_versions", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "ontology_id",   :null => false
    t.string   "source_uri"
    t.string   "raw_file_name"
    t.integer  "raw_file_size"
    t.string   "xml_file_name"
    t.integer  "xml_file_size"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ontology_versions", ["ontology_id"], :name => "index_ontology_versions_on_ontology_id"
  add_index "ontology_versions", ["user_id"], :name => "index_ontology_versions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :null => false
    t.string   "encrypted_password",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  add_foreign_key "ontologies", "logics", :name => "ontologies_logic_id_fk"

  add_foreign_key "ontology_versions", "ontologies", :name => "ontology_versions_ontology_id_fk", :dependent => :delete
  add_foreign_key "ontology_versions", "users", :name => "ontology_versions_user_id_fk"

end
