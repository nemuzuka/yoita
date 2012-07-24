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
end
