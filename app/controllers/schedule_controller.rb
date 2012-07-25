# encoding: utf-8

require "base_controller"

#
# スケジューラのTOP画面を表示するController
#
class ScheduleController < BaseController::HtmlController
  def index
      exeption_handler do
        user_info = get_user_info

        # Session再作成
        re_create_session(user_info)
      end
  end
end
