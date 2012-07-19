# encoding: utf-8
require "constants"
require "service"

#
# 祝日に対するService
#
class NationalHolidaysService < Service::Base
  
  #
  # 指定年の休日データ取得.
  # 指定した年に紐付く休日データを取得します
  # ==== _Args_
  # [target_year]
  #   取得対象年(yyyy)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_target_year(target_year)
    transaction_handler do
      logic = NationalHolidayLogic.new
      logic.find_by_target_year(target_year)
    end
  end
  
  #
  # 祝日登録.
  # 対象年のデータを全て削除した後、祝日を登録します
  # ==== _Args_
  # [target_year]
  #   登録対象年
  # [target_day_list]
  #   登録対象月日配列(MMddフォーマット)
  # [memo_list]
  #   登録対象メモ配列(月日配列とサイズが一致すること)
  #
  def insert_holiday(target_year, target_day_list, memo_list)
    transaction_handler do
      logic = NationalHolidayLogic.new
      logic.insert_holiday(target_year, target_day_list, memo_list)
    end
  end

end
