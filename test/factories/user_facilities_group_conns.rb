# encoding: utf-8

# UserFacilitiesGroupConn用のデフォルト値
FactoryGirl.define do
  # 各種リソース
  factory :user_facilities_group_conn_resource1, :class => Resource do
    id 100001
    resource_type "003"
    name "ユーザグループ1"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource2, :class => Resource do
    id 100002
    resource_type "001"
    name "ユーザA"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource3, :class => Resource do
    id 100003
    resource_type "001"
    name "ユーザB"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource4, :class => Resource do
    id 100004
    resource_type "001"
    name "ユーザC"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource5, :class => Resource do
    id 100005
    resource_type "003"
    name "ユーザグループ2"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource6, :class => Resource do
    id 100006
    resource_type "004"
    name "設備グループ1"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource7, :class => Resource do
    id 100007
    resource_type "002"
    name "設備A"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource8, :class => Resource do
    id 100008
    resource_type "002"
    name "設備B"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end
  factory :user_facilities_group_conn_resource9, :class => Resource do
    id 100009
    resource_type "002"
    name "設備C"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version "0"
  end

  # ユーザグループA
  factory :user_facilities_group_conn1, :class => UserFacilitiesGroupConn do
    id 20000001
    parent_resource_id 100001
    child_resource_id 100001
  end
  factory :user_facilities_group_conn2, :class => UserFacilitiesGroupConn do
    id 20000002
    parent_resource_id 100001
    child_resource_id 100002
  end
  factory :user_facilities_group_conn3, :class => UserFacilitiesGroupConn do
    id 20000003
    parent_resource_id 100001
    child_resource_id 100003
  end
  factory :user_facilities_group_conn4, :class => UserFacilitiesGroupConn do
    id 20000004
    parent_resource_id 100001
    child_resource_id 100004
  end
  # ユーザグループB
  factory :user_facilities_group_conn5, :class => UserFacilitiesGroupConn do
    id 20000005
    parent_resource_id 100005
    child_resource_id 100005
  end
  factory :user_facilities_group_conn6, :class => UserFacilitiesGroupConn do
    id 20000006
    parent_resource_id 100005
    child_resource_id 100002
  end
  factory :user_facilities_group_conn7, :class => UserFacilitiesGroupConn do
    id 20000007
    parent_resource_id 100005
    child_resource_id 100003
  end
  # 設備グループA
  factory :user_facilities_group_conn8, :class => UserFacilitiesGroupConn do
    id 20000008
    parent_resource_id 100006
    child_resource_id 100007
  end
  factory :user_facilities_group_conn9, :class => UserFacilitiesGroupConn do
    id 20000009
    parent_resource_id 100006
    child_resource_id 100008
  end
end
