# encoding: utf-8

#
# 日付加工の際に使用されるヘルパーmodule
#
module DateHelper
  module_function

  #
  # 日付List作成
  # 基準日を元に、指定した日数分のDateのlistを作成します
  # ==== _Args_
  # [base_date]
  #   基準日
  # [days]
  #   作成日付日数
  # ==== _Return_
  # 生成DateList
  #
  def create_date_list(base_date, days)
    ret_list = [base_date]
    target_date = base_date
    count = days - 1
    count.times do
      target_date = target_date + 1
      ret_list.push(target_date)
    end
    return ret_list
  end

  #
  # 時刻フォーマット処理
  # ==== _Args_
  # [target_time]
  #   対象時刻文字列(hhmm形式)
  # ==== _Return_
  # 表示文字列
  #
  def format_time(target_time)
    if target_time.to_s == ''
      return ''
    end
    
    return target_time[0..1] + ":" + target_time[2..3]
  end

  #
  # 月末日取得
  # 対象日を元に、月末を取得します
  # ==== _Args_
  # [target_date]
  #   対象日
  # ==== _Return_
  # 月末日
  #
  def create_end_of_month(target_date)
    start_date = Date.new(target_date.year,target_date.month, 1)
    end_date = start_date >> 1
    return end_date - 1
  end

end
