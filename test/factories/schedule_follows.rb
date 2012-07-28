# encoding: utf-8

FactoryGirl.define do
  factory :schedule_follow1, :class => ScheduleFollow do
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろー"
    entry_resource_id 100002
    update_resource_id 9
    created_at "2010-01-23 12:34:56"
  end

  factory :schedule_follow2, :class => ScheduleFollow do
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろーその2"
    entry_resource_id 100003
    update_resource_id 9
    created_at "2010-02-23 23:45:67"
  end

  factory :schedule_follow3, :class => ScheduleFollow do
    schedule_id 10001
    parent_schedule_follow_id nil
    memo "ふぉろーその3"
    entry_resource_id 1
    update_resource_id 9
    created_at "2010-03-01 00:12:33"
  end

end
