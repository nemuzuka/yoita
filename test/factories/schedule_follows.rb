# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule_follow do
    schedule_id 1
    parent_schedule_follow_id 1
    memo "MyString"
    entry_resource_id 1
    update_resource_id 1
  end
end
