# encoding: utf-8
require 'test_helper'
require "constants"

# ScheduleFollowLogicのテストクラス
class ScheduleFollowLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_schedule_follow_logic
  
  test "get_follow_listのテスト スケジュール作成者" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 100002)
    
    assert_equal actual_list.length, 3
    # スケジュール作成者なので、全てのフォローを削除できる
    assert_equal actual_list[0].schedule_follow[:id], 3
    assert_equal actual_list[0].delete, true
    assert_equal actual_list[0].entry_time, "03/01 00:12"

    assert_equal actual_list[1].schedule_follow[:id], 2
    assert_equal actual_list[1].delete, true
    assert_equal actual_list[1].entry_time, "02/23 23:45"

    assert_equal actual_list[2].schedule_follow[:id], 1
    assert_equal actual_list[2].delete, true
    assert_equal actual_list[2].entry_time, "01/23 12:34"
    
  end

  test "get_follow_listのテスト フォロー作成者" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 1)
    
    assert_equal actual_list.length, 3
    # スケジュール作成者でないので、自分が作成したフォローだけ削除可能
    assert_equal actual_list[0].delete, true
    assert_equal actual_list[1].delete, false
    assert_equal actual_list[2].delete, false
    
  end

  test "get_follow_listのテスト スケジュール作成者でもフォロー作成者でもない" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 4)
    
    assert_equal actual_list.length, 3
    # 全てのフォローに対して削除不可
    assert_equal actual_list[0].delete, false
    assert_equal actual_list[1].delete, false
    assert_equal actual_list[2].delete, false
    
  end
  
end
