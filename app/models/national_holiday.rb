# encoding: utf-8

#
# national_holidaysテーブルのmodel
#
class NationalHoliday < ActiveRecord::Base
  attr_accessible :memo, :target_date, :target_month_day, :target_year

  # validates
  validates :target_year, :length => { :is => 4 }
  validates :target_month_day, :length => { :is => 4 }
  validates :memo, :length => { :maximum  => 1024 }

  #
  # 指定年の休日データ取得.
  # 指定した年に紐付く休日データを取得します
  # ==== _Args_
  # [target_year]
  #   取得対象年(yyyy)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_target_year(target_year)
    national_holidays = Arel::Table.new :national_holidays
    condition = SqlHelper.add_condition(
      nil,
      national_holidays[:target_year].eq(target_year))
    orders = [national_holidays[:target_month_day]];
    self.where(condition).order(orders)
  end

  #
  # 指定期間の休日データ取得.
  # 指定した期間に紐付く休日データを取得します。
  # from日付 <= 対象年月日 <= to日付の関係を満たすデータを返却します
  # ==== _Args_
  # [from_date]
  #   from日付
  # [to_date]
  #   to日付
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_between_date(from_date, to_date)
    national_holidays = Arel::Table.new :national_holidays
    condition = SqlHelper.add_condition(
      nil,
      national_holidays[:target_date].gteq(from_date))
    condition = SqlHelper.add_condition(
      condition,
      national_holidays[:target_date].lteq(to_date))
    orders = [national_holidays[:target_date]];
    self.where(condition).order(orders)
  end

  #
  # 指定年の休日データ削除.
  # 指定した年に紐付く休日データを削除します
  # ==== _Args_
  # [target_year]
  #   取得対象年(yyyy)
  #
  def self.delete_by_target_year(target_year)
    national_holidays = Arel::Table.new :national_holidays
    condition = SqlHelper.add_condition(
      nil,
      national_holidays[:target_year].eq(target_year))
    # delete文発行
    self.delete_all(condition)
  end

end
