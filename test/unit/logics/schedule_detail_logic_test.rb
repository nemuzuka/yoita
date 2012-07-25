# encoding: utf-8
require 'test_helper'
require "constants"

# ScheduleDetailLogicのテストクラス
class ScheduleDetailLogicTest < ActiveSupport::TestCase
  include SetupMethods
  # テスト前処理
  setup :create_schedule_logic

  test "get_detailのテスト 公開、該当レコードあり" do
    logic = ScheduleDetailLogic.new
    actual = logic.get_detail(10001, 4989)
    assert_equal actual.schedule[:id], 10001
    assert_equal actual.schedule_conn_set, SortedSet.new([100001, 100003])
  end

  test "get_detailのテスト 公開、該当レコード無し" do
    logic = ScheduleDetailLogic.new
    begin
      actual = logic.get_detail(19001, 4989)
      assert_false
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

  test "get_detailのテスト 非公開、該当レコードあり、作成者" do
    logic = ScheduleDetailLogic.new
    actual = logic.get_detail(10002, 1)
    assert_equal actual.schedule[:id], 10002
    assert_equal actual.schedule_conn_set, SortedSet.new([100003])
  end

  test "get_detailのテスト 非公開、該当レコードあり、参加者" do
    logic = ScheduleDetailLogic.new
    actual = logic.get_detail(10002, 100003)
    assert_equal actual.schedule[:id], 10002
    assert_equal actual.schedule_conn_set, SortedSet.new([100003])
  end

  test "get_detailのテスト 非公開、該当レコードあり、作成者でなく参加者でない" do
    logic = ScheduleDetailLogic.new
    begin
      actual = logic.get_detail(10002, 4989)
      assert_false
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

end
