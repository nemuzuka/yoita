#
# アプリケーション共通Helper.
#
module ApplicationHelper
  module_function

  #
  # システム日付取得
  # ==== _Return_
  # システム日付
  #
  def get_current_date
    date_str = Time.now.strftime("%Y%m%d")
    p date_str
    date = Date.strptime(date_str, "%Y%m%d")
    p date
    return date
  end


end
