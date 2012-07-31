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
    Time.current.to_date
  end


end
