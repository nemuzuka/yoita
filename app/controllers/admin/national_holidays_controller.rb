# encoding: utf-8

require "base_controller"

module Admin #:nodoc:

  #
  # 祝日管理に関するController
  #
  class NationalHolidaysController < BaseController::HtmlController
    #
    # TOP画面を表示します
    #
    def index
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        user_info = get_user_info
        # Sessionに格納する
        re_create_session(user_info)
      end
    end

  end
end
