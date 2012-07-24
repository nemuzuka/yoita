# encoding: utf-8
require 'test_helper'
require "constants"

# ScheduleLogicのテストクラス
class ScheduleLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_schedule_logic

  test "create_resource_scheduleのテスト 1日1リソース1スケジュール(表示対象スケジュール無し)" do 
    target_dates = [Date.strptime("2010/07/17", "%Y/%m/%d")]
    target_resource_ids = ["100001"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    
    actual_resource_schedule = actual_list[0]
    assert_equal actual_resource_schedule.resource_id, 100001
    assert_equal actual_resource_schedule.name, "ユーザグループ1"
    assert_equal actual_resource_schedule.resource_type, "003"
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
  end

  test "create_resource_scheduleのテスト 1日1リソース1スケジュール(時刻指定なし)" do 
    target_dates = [Date.strptime("2010/07/19", "%Y/%m/%d")]
    target_resource_ids = ["100001"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    
    actual_resource_schedule = actual_list[0]
    assert_equal actual_resource_schedule.resource_id, 100001
    assert_equal actual_resource_schedule.name, "ユーザグループ1"
    assert_equal actual_resource_schedule.resource_type, "003"
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1
    
    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10001
    assert_equal actual_view_schedule.view_title, "・スケジュール1"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, nil
    assert_equal actual_view_schedule.end_time, nil
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
  end

  test "create_resource_scheduleのテスト 1日1リソース1スケジュール(時刻指定あり)、非公開：自分未参加" do 
    target_dates = [Date.strptime("2010/07/20", "%Y/%m/%d")]
    target_resource_ids = ["100003"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    
    actual_resource_schedule = actual_list[0]
    assert_equal actual_resource_schedule.resource_id, 100003
    assert_equal actual_resource_schedule.name, "ユーザB"
    assert_equal actual_resource_schedule.resource_type, "001"
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, nil
    assert_equal actual_view_schedule.view_title, "09:00-09:15 非公開"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "0900"
    assert_equal actual_view_schedule.end_time, "0915"
  end

  test "create_resource_scheduleのテスト 1日1リソース1スケジュール(時刻指定あり)、非公開：自分参加" do 
    target_dates = [Date.strptime("2010/07/20", "%Y/%m/%d")]
    target_resource_ids = ["100003"]
    action_resource_id = "100003"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    
    actual_resource_schedule = actual_list[0]
    assert_equal actual_resource_schedule.resource_id, 100003
    assert_equal actual_resource_schedule.name, "ユーザB"
    assert_equal actual_resource_schedule.resource_type, "001"
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10002
    assert_equal actual_view_schedule.view_title, "09:00-09:15 スケジュール2(非公開)"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "0900"
    assert_equal actual_view_schedule.end_time, "0915"
  end

  test "create_resource_scheduleのテスト 1日1リソース1スケジュール(時刻指定なし)、非公開：自分不参加" do 
    target_dates = [Date.strptime("2010/07/21", "%Y/%m/%d")]
    target_resource_ids = ["100003"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1

    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, nil
    assert_equal actual_view_schedule.view_title, "・非公開"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, nil
    assert_equal actual_view_schedule.end_time, nil
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
  end

  test "create_resource_scheduleのテスト 3日1リソース1スケジュール(日付またぎ)" do 
    target_dates = [Date.strptime("2010/07/22", "%Y/%m/%d"), 
      Date.strptime("2010/07/23", "%Y/%m/%d"), Date.strptime("2010/07/24", "%Y/%m/%d")]
    target_resource_ids = ["100003"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    
    actual_resource_schedule = actual_list[0]
    assert_equal actual_resource_schedule.resource_id, 100003
    assert_equal actual_resource_schedule.name, "ユーザB"
    assert_equal actual_resource_schedule.resource_type, "001"
    
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 3

    # 1日目(07/22分)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10004
    assert_equal actual_view_schedule.view_title, "15:00-07/24 スケジュール4"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "1500"
    assert_equal actual_view_schedule.end_time, "2359"

    # 2日目(07/23分)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10004
    assert_equal actual_view_schedule.view_title, "07/22-07/24 スケジュール4"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "0000"
    assert_equal actual_view_schedule.end_time, "2359"

    # 3日目(07/24分)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10004
    assert_equal actual_view_schedule.view_title, "07/22-13:00 スケジュール4"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "0000"
    assert_equal actual_view_schedule.end_time, "1300"

  end

  test "create_resource_scheduleのテスト 4日1リソース繰り返し毎日" do 
    target_dates = [Date.strptime("2010/08/22", "%Y/%m/%d"), Date.strptime("2010/08/23", "%Y/%m/%d"), 
      Date.strptime("2010/08/24", "%Y/%m/%d"), Date.strptime("2010/08/25", "%Y/%m/%d")]
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 4

    # 1日目(08/22分) 繰り返し期間外
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 2日目(08/23分)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10005
    assert_equal actual_view_schedule.view_title, "10:00-13:00 スケジュール5"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "1000"
    assert_equal actual_view_schedule.end_time, "1300"

    # 3日目(08/24分)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10005
    assert_equal actual_view_schedule.view_title, "10:00-13:00 スケジュール5"
    assert_equal actual_view_schedule.duplicate, false
    assert_equal actual_view_schedule.start_time, "1000"
    assert_equal actual_view_schedule.end_time, "1300"

    # 4日目(08/25分) 繰り返し期間外
    actual_day_schedule = actual_schedule_list[3]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

  end

  test "create_resource_scheduleのテスト 4日1リソース繰り返し毎日(土日を除く)" do 
    target_dates = [Date.strptime("2010/08/27", "%Y/%m/%d"), Date.strptime("2010/08/28", "%Y/%m/%d"), 
      Date.strptime("2010/08/29", "%Y/%m/%d"), Date.strptime("2010/08/30", "%Y/%m/%d")]
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 4

    # 1日目(08/27分)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1
    
    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10006
    assert_equal actual_view_schedule.view_title, "・スケジュール6"

    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 2日目(08/28分)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 3日目(08/29分)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 4日目(08/30分)
    actual_day_schedule = actual_schedule_list[3]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1

    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10006
    assert_equal actual_view_schedule.view_title, "・スケジュール6"
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

  end

  test "create_resource_scheduleのテスト 7日1リソース繰り返し毎週月曜日" do 
    target_date = Date.strptime("2010/09/12", "%Y/%m/%d")
    target_dates = []
    7.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 7

    # 1日目(09/12 日)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 2日目(09/13 月)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1

    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10007
    assert_equal actual_view_schedule.view_title, "・スケジュール7"
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 3日目(09/14 火)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 4日目(09/15 水)
    actual_day_schedule = actual_schedule_list[3]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 5日目(09/16 木)
    actual_day_schedule = actual_schedule_list[4]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 6日目(09/17 金)
    actual_day_schedule = actual_schedule_list[5]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 7日目(09/18 土)
    actual_day_schedule = actual_schedule_list[6]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

  end

  test "create_resource_scheduleのテスト 7日1リソース繰り返し毎月8日" do 
    target_date = Date.strptime("2010/11/04", "%Y/%m/%d")
    target_dates = []
    7.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 7

    # 1日目(11/04)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 2日目(11/05)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0

    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 3日目(11/06)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 4日目(11/07)
    actual_day_schedule = actual_schedule_list[3]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 5日目(11/08)
    actual_day_schedule = actual_schedule_list[4]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1

    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10008
    assert_equal actual_view_schedule.view_title, "・スケジュール8"
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 6日目(11/09)
    actual_day_schedule = actual_schedule_list[5]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 7日目(11/10)
    actual_day_schedule = actual_schedule_list[6]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

  end

  test "create_resource_scheduleのテスト 1リソース繰り返し毎月月末" do 
    target_date = Date.strptime("2010/11/29", "%Y/%m/%d")
    target_dates = []
    4.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 4

    # 1日目(11/29)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 2日目(11/30)
    actual_day_schedule = actual_schedule_list[1]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 1
    
    actual_view_schedule = actual_no_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10009
    assert_equal actual_view_schedule.view_title, "・スケジュール9"

    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
    # 3日目(12/01)
    actual_day_schedule = actual_schedule_list[2]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0

    # 4日目(12/02)
    actual_day_schedule = actual_schedule_list[3]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
        
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 0
    
  end

  test "create_resource_scheduleのテスト 1リソース繰り返し非公開、参加" do 
    target_date = Date.strptime("2011/01/15", "%Y/%m/%d")
    target_dates = []
    1.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100002"]
    action_resource_id = "100003"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    # 1日目(01/15)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10010
    assert_equal actual_view_schedule.view_title, "09:30-10:00 スケジュール10(非公開)"

  end

  test "create_resource_scheduleのテスト 1リソース繰り返し非公開、不参加" do 
    target_date = Date.strptime("2011/01/15", "%Y/%m/%d")
    target_dates = []
    1.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100002"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    # 1日目(01/15)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 1
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, nil
    assert_equal actual_view_schedule.view_title, "09:30-10:00 非公開"

  end

  test "create_resource_scheduleのテスト 重複のテスト" do 
    target_date = Date.strptime("2011/01/20", "%Y/%m/%d")
    target_dates = []
    1.times do
      target_dates.push(target_date)
      target_date = target_date + 1
    end
    
    target_resource_ids = ["100003"]
    action_resource_id = "100001"
    logic = ScheduleLogic.new
    actual_list = logic.create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    assert_equal actual_list.length, 1
    actual_resource_schedule = actual_list[0]
    actual_schedule_list = actual_resource_schedule.schedule_list
    assert_equal actual_schedule_list.length, 1

    # 1日目(01/20)
    actual_day_schedule = actual_schedule_list[0]
    # 時刻指定なしのスケジュール
    actual_no_time_list = actual_day_schedule.no_time_list
    assert_equal actual_no_time_list.length, 0
    
    # 時刻指定ありのスケジュール
    actual_time_list = actual_day_schedule.time_list
    assert_equal actual_time_list.length, 4
    
    actual_view_schedule = actual_time_list[0]
    assert_equal actual_view_schedule.schedule_id, 10014
    assert_equal actual_view_schedule.view_title, "00:00-09:31 スケジュール14"
    assert_equal actual_view_schedule.duplicate, true

    actual_view_schedule = actual_time_list[1]
    assert_equal actual_view_schedule.schedule_id, 10011
    assert_equal actual_view_schedule.view_title, "09:30-10:00 スケジュール11"
    assert_equal actual_view_schedule.duplicate, true

    actual_view_schedule = actual_time_list[2]
    assert_equal actual_view_schedule.schedule_id, 10012
    assert_equal actual_view_schedule.view_title, "09:45-12:00 スケジュール12"
    assert_equal actual_view_schedule.duplicate, true

    actual_view_schedule = actual_time_list[3]
    assert_equal actual_view_schedule.schedule_id, 10013
    assert_equal actual_view_schedule.view_title, "12:00-12:45 スケジュール13"
    assert_equal actual_view_schedule.duplicate, false

  end



end
