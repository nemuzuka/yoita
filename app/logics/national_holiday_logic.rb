# encoding: utf-8

#
# 祝日に関するLogic
#
class NationalHolidayLogic

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
    NationalHoliday.find_by_target_year(target_year)
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
  def find_by_between_date(from_date, to_date)
    NationalHoliday.find_by_between_date(from_date, to_date)
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
    
    # validate
    validate(target_year, target_day_list, memo_list)
    
    ins_hash = {}
    target_day_list.each_with_index do |target, index|
      if target.to_s != ''
        ins_hash[target] = memo_list[index]
      end
    end
    
    # 登録済みデータを削除
    NationalHoliday.delete_by_target_year(target_year)
    
    # データ登録
    ins_hash.each do |key, value|
      national_holiday = NationalHoliday.new
      national_holiday[:target_year] = target_year
      national_holiday[:target_month_day] = key
      national_holiday[:memo] = value
      national_holiday[:target_date] = Date.strptime(target_year + key, "%Y%m%d")
      national_holiday.save!
    end
  end
  
  private 
    #
    # validate
    # 引数のlistのサイズが一致すること
    # 月日配列の値が日付として有効であること
    # のチェックを行います
    # ==== _Args_
    # [target_year]
    #   登録対象年
    # [target_day_list]
    #   登録対象月日配列
    # [memo_list]
    #   登録対象メモ配列
    #
    def validate(target_year, target_day_list, memo_list)
      if target_day_list.length != memo_list.length
        raise CustomException::ValidationException.new(["日付とコメントの数が合致しません"])
      end
      
      error_msgs = []
      target_day_list.each_with_index do |target, index|
        if target.to_s != ''
          begin
            Date.strptime(target_year + target, "%Y%m%d")
          rescue ArgumentError => e
            # 変換できないエラーが出るはず
            error_msgs.push((index + 1).to_s + "番目の日付指定が不正です")
          end
        end
      end
      
      if error_msgs.length != 0
        raise CustomException::ValidationException.new(error_msgs)
      end
      
    end
end