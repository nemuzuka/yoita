# encoding: utf-8
require 'test_helper'

# NationalHolidayLogicのテストクラス
class NationalHolidayLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_national_holiday
  
  test "insert_holidayのテスト" do
    
    logic = NationalHolidayLogic.new
    actual_list = logic.find_by_target_year("2010")
    assert_equal actual_list.length, 4
    
    target_day_list = ["0201", "0110"]
    memo_list = ["メモ1", "メモ2"]
    
    logic.insert_holiday("2010", target_day_list, memo_list)
    
    actual_list = logic.find_by_target_year("2010")
    assert_equal actual_list.length, 2
    assert_equal actual_list[0][:target_date], Date.strptime("2010-01-10", "%Y-%m-%d")
    assert_equal actual_list[0][:memo], "メモ2"
    assert_equal actual_list[1][:target_date], Date.strptime("2010-02-01", "%Y-%m-%d")
    assert_equal actual_list[1][:memo], "メモ1"
    
  end

  test "insert_holidayのテスト2" do
    
    # 登録するデータ無し
    logic = NationalHolidayLogic.new
    actual_list = logic.find_by_target_year("2010")
    assert_equal actual_list.length, 4
    
    target_day_list = []
    memo_list = []
    
    logic.insert_holiday("2010", target_day_list, memo_list)
    
    actual_list = logic.find_by_target_year("2010")
    assert_equal actual_list.length, 0
    
  end

  
  test "insert_holidayのvalidateエラー" do
    # サイズが違う
    target_day_list = ["0101", "0501", "0430"]
    memo_list = ["メモ1", "メモ2", "メモ3", "余計なメモ"]
    
    logic = NationalHolidayLogic.new
    begin
      logic.insert_holiday("2010", target_day_list, memo_list)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end

    # 日付フォーマットが不正
    target_day_list = ["01/01", "0229"]
    memo_list = ["メモ1", ""]
    begin
      logic.insert_holiday("2011", target_day_list, memo_list)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 2
    end
  end
  
end
