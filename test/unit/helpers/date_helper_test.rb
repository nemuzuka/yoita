# encoding: utf-8
require 'test_helper'

class DateHelperTest < ActionView::TestCase
  
  include DateHelper
  
  test "create_date_listのテスト" do
    base_date = Date.strptime("2010/01/01", "%Y/%m/%d")
    actual_list = create_date_list(base_date, 3)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_list[1], Date.strptime("2010/01/02", "%Y/%m/%d")
    assert_equal actual_list[2], Date.strptime("2010/01/03", "%Y/%m/%d")
    
  end

  test "format_timeのテスト" do
    assert_equal format_time("1234"), "12:34"
    assert_equal format_time(nil), ""
    assert_equal format_time(""), ""
    assert_equal format_time("2345"), "23:45"
  end
  
  test "range_checkのテスト" do
    # 基準が範囲のテスト
    assert_equal range_check("1000", "1100", "1030", "1130"), true
    assert_equal range_check("1000", "1100", "1100", "1130"), false
    assert_equal range_check("1000", "1100", "1101", "1130"), false
    assert_equal range_check("1000", "1100", "0930", "1030"), true
    assert_equal range_check("1000", "1100", "0930", "1000"), false
    assert_equal range_check("1000", "1100", "0930", "0959"), false
    assert_equal range_check("1000", "1100", "1000", "1100"), true
    assert_equal range_check("1000", "1100", "0959", "1101"), true
    assert_equal range_check("1000", "1100", "1001", "1059"), true
    assert_equal range_check("1000", "1100", "0959", "0959"), false
    assert_equal range_check("1000", "1100", "1000", "1000"), true
    assert_equal range_check("1000", "1100", "1030", "1030"), true
    assert_equal range_check("1000", "1100", "1100", "1100"), true
    assert_equal range_check("1000", "1100", "1101", "1101"), false
    
    # 基準が点のテスト
    assert_equal range_check("1030", "1030", "1030", "1031"), true
    assert_equal range_check("1030", "1030", "1031", "1032"), false
    assert_equal range_check("1030", "1030", "1029", "1030"), true
    assert_equal range_check("1030", "1030", "1028", "1029"), false
    assert_equal range_check("1030", "1030", "1029", "1031"), true
    assert_equal range_check("1030", "1030", "1029", "1029"), false
    assert_equal range_check("1030", "1030", "1030", "1030"), true
    assert_equal range_check("1030", "1030", "1031", "1031"), false
  end
  
  test "time_string?のテスト" do
    assert_equal time_string?(""), true
    assert_equal time_string?("123"), false
    assert_equal time_string?("0000"), true
    assert_equal time_string?("0001"), true
    assert_equal time_string?("0159"), true
    assert_equal time_string?("0160"), false
    assert_equal time_string?("2358"), true
    assert_equal time_string?("2359"), true
    assert_equal time_string?("2400"), false
  end
  
  test "create_month_date_listのテスト" do
    actual_list = create_month_date_list("201207")
    assert_equal actual_list.length, 35
    assert_equal actual_list[0], Date.strptime("20120701","%Y%m%d")
    assert_equal actual_list[actual_list.length - 1], Date.strptime("20120804","%Y%m%d")

    actual_list = create_month_date_list("201208")
    assert_equal actual_list[0], Date.strptime("20120729","%Y%m%d")
    assert_equal actual_list[actual_list.length - 1], Date.strptime("20120901","%Y%m%d")

    actual_list = create_month_date_list("201206")
    assert_equal actual_list[0], Date.strptime("20120527","%Y%m%d")
    assert_equal actual_list[actual_list.length - 1], Date.strptime("20120630","%Y%m%d")
    
  end
  
  test "add_monthのテスト" do
    assert_equal add_month("201001", 1), "201002"
    assert_equal add_month("201001", -1), "200912"
    assert_equal add_month("201012", 1), "201101"
  end
  
end
