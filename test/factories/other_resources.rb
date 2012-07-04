# encoding: utf-8

# Resource用のデフォルト値
FactoryGirl.define do
  factory :resource8, :class => Resource do
    id 100008
    resource_type "abc"
    name "あいうえお"
    memo "かきくけこ"
    sort_num 15
    entry_resource_id 36987
    update_resource_id 7412580
    lock_version 4989
  end
end
