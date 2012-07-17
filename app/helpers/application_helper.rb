#
# アプリケーション共通Helper.
#
module ApplicationHelper

  #
  # システム日付取得
  # ==== _Return_
  # システム日付
  #
  def get_current_date
    Date.today
  end

  module_function :get_current_date

end
