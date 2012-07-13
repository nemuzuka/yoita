# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :login do
    resource_id 1
    login_id "MyString"
    password "MyString"
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end
end
