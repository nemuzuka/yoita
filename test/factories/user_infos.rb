# encoding: utf-8

FactoryGirl.define do

  # 各種リソース
  factory :user_info_resource1, :class => Resource do
    id 100001
    resource_type "001"
    name "ユーザA"
    memo ""
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 1
  end
  factory :user_info_resource2, :class => Resource do
    id 100002
    resource_type "001"
    name "ユーザB"
    memo "ああああ"
    sort_num "1"
    entry_resource_id "11111"
    update_resource_id "22222"
    lock_version 2
  end

  # user_infos
  factory :user_info1, :class => UserInfo do
    resource_id 100001
    reading_character "ユーザAのふりがな"
    tel "123-456-7890"
    mail "hige@hoge.hage"
    admin_flg "1"
    per_page 1
    default_user_group 1
    validity_start_date "2011-07-01"
    validity_end_date "2011-07-31"
    entry_resource_id 1234
    update_resource_id 5678
    lock_version 11
  end

  factory :user_info2, :class => UserInfo do
    resource_id 100002
    reading_character "ユーザBのふりがな"
    tel "234-567-8901"
    mail "hige2@hoge.hage"
    admin_flg "0"
    per_page 10
    default_user_group 1
    validity_start_date "2012-07-01"
    validity_end_date "2012-07-31"
    entry_resource_id 9012
    update_resource_id 1123
    lock_version 12
  end

  # logins
  factory :login1, :class => Login do
    resource_id 100001
    login_id "hohohoge1"
    password "意味なしパスワード"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 21
  end

  factory :login2, :class => Login do
    resource_id 100002
    login_id "hohohoge2"
    password "意味なしパスワード2"
    entry_resource_id 87654
    update_resource_id 12345678
    lock_version 22
  end


end
