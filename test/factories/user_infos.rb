# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_info do
    resource_id 1
    reading_character "MyString"
    tel "MyString"
    mail "MyString"
    admin_flg "MyString"
    per_page 1
    default_user_group 1
    validity_start_date "2012-07-12"
    validity_end_date "2012-07-12"
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end
end
