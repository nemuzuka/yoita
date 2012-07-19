# encoding: utf-8
require 'test_helper'

class NationalHolidayTest < ActiveSupport::TestCase

  include SetupMethods
  # テスト前処理
  setup :create_national_holiday

  test "find_by_target_yearのテスト" do
    actual_list = NationalHoliday.find_by_target_year("2010")
    assert_equal actual_list.length, 4
    assert_equal actual_list[0], FactoryGirl.build(:national_holiday1)
    assert_equal actual_list[1], FactoryGirl.build(:national_holiday2)
    assert_equal actual_list[2], FactoryGirl.build(:national_holiday3)
    assert_equal actual_list[3], FactoryGirl.build(:national_holiday4)

    # 指定対象年に該当するレコードが存在しない場合
    actual_list = NationalHoliday.find_by_target_year("2009")
    assert_equal actual_list.length, 0
  end

  test "find_by_between_dateのテスト" do
    from_date = Date.strptime("2010/01/02", "%Y/%m/%d")
    to_date = Date.strptime("2010/01/03", "%Y/%m/%d")
    actual_list = NationalHoliday.find_by_between_date(from_date, to_date)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:national_holiday2)
    assert_equal actual_list[1], FactoryGirl.build(:national_holiday3)

    from_date = Date.strptime("2010/01/01", "%Y/%m/%d")
    to_date = Date.strptime("2011/01/01", "%Y/%m/%d")
    actual_list = NationalHoliday.find_by_between_date(from_date, to_date)
    assert_equal actual_list.length, 5
    assert_equal actual_list[0], FactoryGirl.build(:national_holiday1)
    assert_equal actual_list[1], FactoryGirl.build(:national_holiday2)
    assert_equal actual_list[2], FactoryGirl.build(:national_holiday3)
    assert_equal actual_list[3], FactoryGirl.build(:national_holiday4)
    assert_equal actual_list[4], FactoryGirl.build(:national_holiday5)

    from_date = Date.strptime("2009/01/01", "%Y/%m/%d")
    to_date = Date.strptime("2009/12/31", "%Y/%m/%d")
    actual_list = NationalHoliday.find_by_between_date(from_date, to_date)
    assert_equal actual_list.length, 0

  end

  test "delete_by_target_yearのテスト" do
    assert_equal NationalHoliday.find(:all).length, 8

    NationalHoliday.delete_by_target_year("2010")
    actual_list = NationalHoliday.find_by_target_year("2010")
    assert_equal actual_list.length, 0

    assert_equal NationalHoliday.find(:all).length, 4
  end

  test "delete_by_target_yearのテスト 削除件数0件" do
    assert_equal NationalHoliday.find(:all).length, 8

    NationalHoliday.delete_by_target_year("2009")

    assert_equal NationalHoliday.find(:all).length, 8
  end

end
