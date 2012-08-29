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
  factory :user_info_resource3, :class => Resource do
    id 100003
    resource_type "001"
    name "検索用ユーザ1-1"
    memo "memo1-1"
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 10001
  end
  factory :user_info_resource4, :class => Resource do
    id 100004
    resource_type "001"
    name "検索用ユーザ2-1"
    memo "memo2-1"
    sort_num "1"
    entry_resource_id "11111"
    update_resource_id "22222"
    lock_version 10002
  end
  factory :user_info_resource5, :class => Resource do
    id 100005
    resource_type "001"
    name "検索用ユーザ3-1"
    memo "memo3-1"
    sort_num "9"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 10003
  end
  factory :user_info_resource6, :class => Resource do
    id 100006
    resource_type "001"
    name "検索用ユーザ3-2"
    memo "memo3-2"
    sort_num "2"
    entry_resource_id "11111"
    update_resource_id "22222"
    lock_version 10004
  end
  factory :user_info_resource7, :class => Resource do
    id 100007
    resource_type "002"
    name "検索用ユーザ1-1(でも設備)"
    memo "memo1-1 設備"
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 10009
  end
  factory :user_info_resource8, :class => Resource do
    id 100008
    resource_type "003"
    name "検索用ユーザ1-1(でもユーザグループ)"
    memo "memo1-1 ユーザグループ"
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 10010
  end
  factory :user_info_resource9, :class => Resource do
    id 100009
    resource_type "004"
    name "検索用ユーザ1-1(でも設備グループ)"
    memo "memo1-1 設備グループ"
    sort_num "1"
    entry_resource_id "1"
    update_resource_id "1"
    lock_version 10011
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

  factory :user_info3, :class => UserInfo do
    resource_id 100003
    reading_character "ゆーざ1-1"
    tel "tel-001"
    mail "user1-1@mail.com"
    admin_flg "0"
    per_page 10
    default_user_group 1
    validity_start_date "2010-01-01"
    validity_end_date "2010-01-01"
    entry_resource_id 9012
    update_resource_id 1123
    lock_version 201
  end

  factory :user_info4, :class => UserInfo do
    resource_id 100004
    reading_character "ゆーざ2-1"
    tel "tel-002"
    mail "user2-1@mail.com"
    admin_flg "1"
    per_page 10
    default_user_group 1
    validity_start_date "2009-12-31"
    validity_end_date "2010-01-01"
    entry_resource_id 9012
    update_resource_id 1123
    lock_version 202
  end

  factory :user_info5, :class => UserInfo do
    resource_id 100005
    reading_character "ゆーざ3-1"
    tel "tel-003"
    mail "user3-1@mail.com"
    admin_flg "0"
    per_page 10
    default_user_group 1
    validity_start_date "2001-01-01"
    validity_end_date "2010-01-02"
    entry_resource_id 9012
    update_resource_id 1123
    lock_version 203
  end

  factory :user_info6, :class => UserInfo do
    resource_id 100006
    reading_character "ゆーざ3-2"
    tel "tel-004"
    mail "user3-2@mail.com"
    admin_flg "1"
    per_page 10
    default_user_group 1
    validity_start_date "2001-01-01"
    validity_end_date "2010-01-03"
    entry_resource_id 9012
    update_resource_id 1123
    lock_version 204
  end

  # logins
  factory :login1, :class => Login do
    resource_id 100001
    login_id "hohohoge1"
    provider "Y"
    password "意味なしパスワード"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 21
  end

  factory :login2, :class => Login do
    resource_id 100002
    login_id "hohohoge2"
    provider "Y"
    password "意味なしパスワード2"
    entry_resource_id 87654
    update_resource_id 12345678
    lock_version 22
  end

  factory :login3, :class => Login do
    resource_id 100003
    login_id "user1-1"
    provider "Y"
    password "password"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 301
  end

  factory :login4, :class => Login do
    resource_id 100004
    login_id "user2-1"
    provider "Y"
    password "password"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 302
  end
  
  factory :login5, :class => Login do
    resource_id 100005
    login_id "user3-1"
    provider "Y"
    password "password"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 303
  end

  factory :login6, :class => Login do
    resource_id 100006
    login_id "user3-2"
    provider "Y"
    password "password"
    entry_resource_id 3335
    update_resource_id 45678
    lock_version 304
  end

end
