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

ActiveRecord::Schema.define(:version => 20120719023221) do

  create_table "logins", :force => true do |t|
    t.integer  "resource_id",        :limit => 8
    t.string   "login_id",           :limit => 256
    t.string   "password",           :limit => 256
    t.integer  "entry_resource_id",  :limit => 8
    t.integer  "update_resource_id", :limit => 8
    t.integer  "lock_version",       :limit => 8,   :default => 0
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
  end

  add_index "logins", ["login_id"], :name => "login_unique_idx_01", :unique => true
  add_index "logins", ["resource_id"], :name => "login_idx_01"

  create_table "national_holidays", :force => true do |t|
    t.string "target_year",      :limit => 4
    t.string "target_month_day", :limit => 4
    t.date   "target_date"
    t.string "memo",             :limit => 1024
  end

  add_index "national_holidays", ["target_date"], :name => "national_holidays_unique_idx_01", :unique => true
  add_index "national_holidays", ["target_year"], :name => "national_holidays_idx_01"

  create_table "resources", :force => true do |t|
    t.string   "resource_type",      :limit => 3
    t.string   "name",               :limit => 128
    t.string   "memo",               :limit => 1024
    t.integer  "sort_num",           :limit => 8
    t.integer  "entry_resource_id",  :limit => 8
    t.integer  "update_resource_id", :limit => 8
    t.integer  "lock_version",       :limit => 8,    :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "resources", ["name"], :name => "resource_idx_01"
  add_index "resources", ["resource_type"], :name => "resource_idx_02"
  add_index "resources", ["sort_num"], :name => "resource_idx_03"

  create_table "user_facilities_group_conns", :force => true do |t|
    t.integer "parent_resource_id", :limit => 8
    t.integer "child_resource_id",  :limit => 8
  end

  add_index "user_facilities_group_conns", ["parent_resource_id"], :name => "user_facilities_group_conn_idx_01"

  create_table "user_infos", :force => true do |t|
    t.integer  "resource_id",         :limit => 8
    t.string   "reading_character",   :limit => 128
    t.string   "tel",                 :limit => 48
    t.string   "mail",                :limit => 256
    t.string   "admin_flg",           :limit => 1
    t.integer  "per_page"
    t.integer  "default_user_group",  :limit => 8
    t.date     "validity_start_date"
    t.date     "validity_end_date"
    t.integer  "entry_resource_id",   :limit => 8
    t.integer  "update_resource_id",  :limit => 8
    t.integer  "lock_version",        :limit => 8,   :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "user_infos", ["reading_character"], :name => "user_info_idx_03"
  add_index "user_infos", ["resource_id"], :name => "user_info_idx_01"
  add_index "user_infos", ["validity_start_date", "validity_end_date"], :name => "user_info_idx_02"

end
