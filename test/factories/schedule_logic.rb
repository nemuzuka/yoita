# encoding: utf-8

FactoryGirl.define do
  factory :schedule1, :class => Schedule do
    id 10001
    title "スケジュール1"
    memo "スケジュールメモ1(繰り返しでない)"
    closed_flg "0"
    start_date "2010-07-19"
    start_time ""
    end_date "2010-07-19"
    end_time ""
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule2, :class => Schedule do
    id 10002
    title "スケジュール2"
    memo "スケジュールメモ2(繰り返しでない、非公開)"
    closed_flg "1"
    start_date "2010-07-20"
    start_time "0900"
    end_date "2010-07-20"
    end_time "0915"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule3, :class => Schedule do
    id 10003
    title "スケジュール3"
    memo "スケジュールメモ3(繰り返しでない、非公開)"
    closed_flg "1"
    start_date "2010-07-21"
    start_time ""
    end_date "2010-07-21"
    end_time ""
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule4, :class => Schedule do
    id 10004
    title "スケジュール4"
    memo "複数日にまたがる"
    closed_flg "0"
    start_date "2010-07-22"
    start_time "1500"
    end_date "2010-07-24"
    end_time "1300"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule5, :class => Schedule do
    id 10005
    title "スケジュール5"
    memo "繰り返し、毎日"
    closed_flg "0"
    start_date "2010-08-23"
    start_time "1000"
    end_date "2010-08-24"
    end_time "1300"
    repeat_conditions "1"
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule6, :class => Schedule do
    id 10006
    title "スケジュール6"
    memo "繰り返し、毎日(土日を除く)"
    closed_flg "0"
    start_date "2010-08-26"
    start_time ""
    end_date "2010-09-10"
    end_time ""
    repeat_conditions "2"
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule7, :class => Schedule do
    id 10007
    title "スケジュール7"
    memo "繰り返し、毎週月曜日"
    closed_flg "0"
    start_date "2010-09-11"
    start_time ""
    end_date "2010-10-10"
    end_time ""
    repeat_conditions "3"
    repeat_week "1"
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule8, :class => Schedule do
    id 10008
    title "スケジュール8"
    memo "繰り返し、毎月8日"
    closed_flg "0"
    start_date "2010-10-11"
    start_time ""
    end_date "2010-11-10"
    end_time ""
    repeat_conditions "4"
    repeat_week ""
    repeat_day "08"
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule9, :class => Schedule do
    id 10009
    title "スケジュール9"
    memo "繰り返し、毎月月末"
    closed_flg "0"
    start_date "2010-11-11"
    start_time ""
    end_date "2010-12-31"
    end_time ""
    repeat_conditions "4"
    repeat_week ""
    repeat_day "32"
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule10, :class => Schedule do
    id 10010
    title "スケジュール10"
    memo "繰り返し、毎日、非公開"
    closed_flg "1"
    start_date "2011-01-15"
    start_time "0930"
    end_date "2011-01-18"
    end_time "1000"
    repeat_conditions "1"
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule11, :class => Schedule do
    id 10011
    title "スケジュール11"
    memo "重複スケジュール"
    closed_flg "0"
    start_date "2011-01-20"
    start_time "0930"
    end_date "2011-01-20"
    end_time "1000"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule12, :class => Schedule do
    id 10012
    title "スケジュール12"
    memo "重複スケジュールその2"
    closed_flg "0"
    start_date "2011-01-20"
    start_time "0945"
    end_date "2011-01-20"
    end_time "1200"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule13, :class => Schedule do
    id 10013
    title "スケジュール13"
    memo "重複なしスケジュール"
    closed_flg "0"
    start_date "2011-01-20"
    start_time "1200"
    end_date "2011-01-20"
    end_time "1245"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule14, :class => Schedule do
    id 10014
    title "スケジュール14"
    memo "重複スケジュールその3"
    closed_flg "0"
    start_date "2011-01-20"
    start_time "0000"
    end_date "2011-01-20"
    end_time "0931"
    repeat_conditions ""
    repeat_week ""
    repeat_day ""
    repeat_endless ""
    entry_resource_id 1
    update_resource_id 1
    lock_version 1
  end

  factory :schedule_conn1, :class => ScheduleConn do
    schedule_id 10001
    resource_id 100001
  end

  factory :schedule_conn2, :class => ScheduleConn do
    schedule_id 10001
    resource_id 100003
  end

  factory :schedule_conn3, :class => ScheduleConn do
    schedule_id 10002
    resource_id 100003
  end

  factory :schedule_conn4, :class => ScheduleConn do
    schedule_id 10003
    resource_id 100003
  end

  factory :schedule_conn5, :class => ScheduleConn do
    schedule_id 10004
    resource_id 100003
  end

  factory :schedule_conn6, :class => ScheduleConn do
    schedule_id 10005
    resource_id 100002
  end

  factory :schedule_conn7, :class => ScheduleConn do
    schedule_id 10006
    resource_id 100002
  end

  factory :schedule_conn8, :class => ScheduleConn do
    schedule_id 10007
    resource_id 100002
  end

  factory :schedule_conn9, :class => ScheduleConn do
    schedule_id 10008
    resource_id 100002
  end

  factory :schedule_conn10, :class => ScheduleConn do
    schedule_id 10009
    resource_id 100002
  end

  factory :schedule_conn11, :class => ScheduleConn do
    schedule_id 10010
    resource_id 100002
  end

  factory :schedule_conn12, :class => ScheduleConn do
    schedule_id 10010
    resource_id 100003
  end

  factory :schedule_conn13, :class => ScheduleConn do
    schedule_id 10011
    resource_id 100003
  end

  factory :schedule_conn14, :class => ScheduleConn do
    schedule_id 10012
    resource_id 100003
  end

  factory :schedule_conn15, :class => ScheduleConn do
    schedule_id 10013
    resource_id 100003
  end

  factory :schedule_conn16, :class => ScheduleConn do
    schedule_id 10014
    resource_id 100003
  end
  
end
