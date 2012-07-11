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

ActiveRecord::Schema.define(:version => 20120711003142) do

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

end
