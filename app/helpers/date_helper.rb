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

  #
  # 範囲チェック
  # 対象となる時刻が、基準となる時刻に被るかチェックします
  # ==== _Args_
  # [base_from]
  #   基準From(HHmm形式)
  # [base_to]
  #   基準To(HHmm形式)
  # [target_from]
  #   対象From(HHmm形式)
  # [target_to]
  #   対象To(HHmm形式)
  # ==== _Return_
  # 重複する場合、true
  #
  def range_check(base_from, base_to, target_from, target_to)
    if base_from > base_to || target_from > target_to
      return false
    end
    
    # 基準の開始が対象From～対象Toの間に含まれる場合
    if target_from <= base_from && base_from < target_to
      return true
    end

    # 基準の終了が対象From～対象Toの間に含まれる場合
    if target_from < base_to && base_to <= target_to
      return true
    end

    # 基準の範囲内に収まる場合
    if base_from <= target_from && target_from <= base_to &&
        base_from <= target_to && target_to <= base_to
      return true
    end

    return false
  end

  #
  # 時刻文字列か？
  # 対象文字列が空文字か時刻文字列の場合、時刻文字列と判断します
  # ==== _Args_
  # [target]
  #   対象文字列(HHmm形式)
  # ==== _Return_
  # 時刻文字列でない場合、false
  #
  def time_string?(target)
    if target.to_s == ''
      return true
    end
    
    if target.length != 4
      return false
    end

    begin
      Time.strptime(target, "%H%M")
    rescue ArgumentError
      return false
    end
    
    if (target.to_i / 100) > 23
      # 0000〜2359までを有効なデータとしたい
      return false
    end

    return true
  end

  #
  # 時刻文字列生成
  # ==== _Args_
  # [time]
  #   Timeオブジェクト
  # [format]
  #   format文字列
  # ==== _Return_
  # 時刻文字列(該当データが存在しなければ空文字)
  #
  def get_formated_time(time, format = "%Y/%m/%d %H:%M")
    if time == nil
      return ""
    end
    
    return time.strftime(format)
  end
  
end
