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
    assert_equal actual_list[0].schedule_follow[:id], 1234569
    assert_equal actual_list[0].delete_follow, true
    assert_equal actual_list[0].entry_time, "03/01 00:12"

    assert_equal actual_list[1].schedule_follow[:id], 1234568
    assert_equal actual_list[1].delete_follow, true
    assert_equal actual_list[1].entry_time, "02/23 23:45"

    assert_equal actual_list[2].schedule_follow[:id], 1234567
    assert_equal actual_list[2].delete_follow, true
    assert_equal actual_list[2].entry_time, "01/23 12:34"
    
  end

  test "get_follow_listのテスト フォロー作成者" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 1)
    
    assert_equal actual_list.length, 3
    # スケジュール作成者でないので、自分が作成したフォローだけ削除可能
    assert_equal actual_list[0].delete_follow, true
    assert_equal actual_list[1].delete_follow, false
    assert_equal actual_list[2].delete_follow, false
    
  end

  test "get_follow_listのテスト スケジュール作成者でもフォロー作成者でもない" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 4)
    
    assert_equal actual_list.length, 3
    # 全てのフォローに対して削除不可
    assert_equal actual_list[0].delete_follow, false
    assert_equal actual_list[1].delete_follow, false
    assert_equal actual_list[2].delete_follow, false
  end
  
  test "saveのテスト 登録されることの確認" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10004", 4)
    assert_equal actual_list.length, 0

    params = {
      :schedule_follow => {
        :schedule_id => "10004",
        :memo => "めもでっせ",
        :parent_schedule_follow_id => nil
      }
    }
    
    logic.save(params, "4")
    
    actual_list = logic.get_follow_list("10004", 4)
    assert_equal actual_list.length, 1
  end
  
  test "saveのテスト 存在しないスケジュールに対する追加" do
    params = {
      :schedule_follow => {
        :schedule_id => "18004",
        :memo => "めもでっせ",
        :parent_schedule_follow_id => nil
      }
    }
    
    logic = ScheduleFollowLogic.new
    begin
      logic.save(params, "4")
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

  test "saveのテスト 非公開で参加していないスケジュールに対するフォロー追加" do
    params = {
      :schedule_follow => {
        :schedule_id => "10002",
        :memo => "めもでっせ",
        :parent_schedule_follow_id => nil
      }
    }
    
    logic = ScheduleFollowLogic.new
    begin
      logic.save(params, 100004)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

  test "deleteのテスト 正常終了" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 4)
    assert_equal actual_list.length, 3
    
    logic = ScheduleFollowLogic.new
    logic.delete("10001", "1234567", 100002)

    actual_list = logic.get_follow_list("10001", 4)
    assert_equal actual_list.length, 2
  end

  test "deleteのテスト フォロー追加者でも、スケジュール作成者でもない" do
    logic = ScheduleFollowLogic.new
    actual_list = logic.get_follow_list("10001", 100002)
    assert_equal actual_list.length, 3
    
    logic = ScheduleFollowLogic.new
    begin
      logic.delete("10001", "1234567", 100004)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end
  end
  
end
