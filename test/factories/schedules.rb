# encoding: utf-8

FactoryGirl.define do
  factory :schedule_model1, :class => Schedule do
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

  factory :schedule_conn_model1, :class => ScheduleConn do
    schedule_id 10001
    resource_id 100001
  end

  factory :schedule_conn_model2, :class => ScheduleConn do
    schedule_id 10001
    resource_id 100003
  end

end
