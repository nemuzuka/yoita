# encoding: utf-8

require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_schedule
  
  test "get_schedule_listのテスト" do
    target_date = Date.strptime("2010/07/19", "%Y/%m/%d")
    actual_list = Schedule.get_schedule_list([100001, "100003"], target_date, target_date)
    assert_equal actual_list.length, 2

    actual_list = Schedule.get_schedule_list([100003], target_date, target_date)
    assert_equal actual_list.length, 1

    actual_list = Schedule.get_schedule_list(["100004"], target_date, target_date)
    assert_equal actual_list.length, 0

  end
  
end
