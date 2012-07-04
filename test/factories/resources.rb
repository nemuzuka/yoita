# encoding: utf-8

# Resource用のデフォルト値
FactoryGirl.define do
  factory :resource1, :class => Resource do
    id 100001
    resource_type "MyS"
    name "MyS%tring1"
    memo "memo1"
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "1"
  end

  factory :resource2, :class => Resource do
    id 100002
    resource_type "123"
    name "MyString2"
    memo "memo2"
    sort_num "2"
    entry_resource_id "2"
    update_resource_id "3"
    lock_version "4"
  end

  factory :resource3, :class => Resource do
    id 100003
    resource_type "MyS"
    name "MyString21"
    memo "memo3"
    sort_num "1"
    entry_resource_id "5"
    update_resource_id "6"
    lock_version "7"
  end

  factory :resource4, :class => Resource do
    id 100004
    resource_type "hog"
    name "MyS％tring1"
    memo "memo4"
    sort_num "999"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "1"
  end

  factory :resource5, :class => Resource do
    id 100005
    resource_type "hog"
    name "MyS_tring1"
    memo "memo5"
    sort_num "999"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "1"
  end

  factory :resource6, :class => Resource do
    id 100006
    resource_type "hog"
    name "MyS＿tring1"
    memo "memo5"
    sort_num "999"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "1"
  end

  factory :resource7, :class => Resource do
    id 100007
    resource_type "hog"
    name "MyS\\tring1"
    memo "memo5"
    sort_num "999"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "1"
  end

end
