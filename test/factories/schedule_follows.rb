# encoding: utf-8

FactoryGirl.define do
  factory :schedule_follow1, :class => ScheduleFollow do
    id 1234567
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろー"
    entry_resource_id 100002
    update_resource_id 9
    created_at "2010-01-23 12:34:56"
  end

  factory :schedule_follow2, :class => ScheduleFollow do
    id 1234568
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろーその2"
    entry_resource_id 100003
    update_resource_id 9
    created_at "2010-02-23 23:45:67"
  end

  factory :schedule_follow3, :class => ScheduleFollow do
    id 1234569
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろーその3"
    entry_resource_id 1
    update_resource_id 9
    created_at "2010-03-01 00:12:33"
  end

  factory :schedule_follow4, :class => ScheduleFollow do
    id 1234570
    schedule_id 10005
    parent_schedule_follow_id nil
    memo "親フォロー1"
    entry_resource_id 100002
    update_resource_id 9
    created_at "2010-01-23 12:34:56"
  end

  factory :schedule_follow5, :class => ScheduleFollow do
    id 1234571
    schedule_id 10005
    parent_schedule_follow_id 1234570
    memo "フォロー1-2"
    entry_resource_id 100003
    update_resource_id 9
    created_at "2010-02-24 23:45:67"
  end

  factory :schedule_follow6, :class => ScheduleFollow do
    id 1234572
    schedule_id 10005
    parent_schedule_follow_id nil
    memo "親フォロー2"
    entry_resource_id 1
    update_resource_id 9
    created_at "2010-03-25 00:12:33"
  end

  factory :schedule_follow7, :class => ScheduleFollow do
    id 1234573
    schedule_id 10005
    parent_schedule_follow_id 1234570
    memo "フォロー1-2"
    entry_resource_id 1
    update_resource_id 9
    created_at "2010-03-26 00:12:33"
  end

  factory :schedule_follow8, :class => ScheduleFollow do
    id 1234574
    schedule_id 10005
    parent_schedule_follow_id 1234572
    memo "ふぉろー2-2"
    entry_resource_id 1
    update_resource_id 9
    created_at "2010-03-27 00:12:33"
  end

end
