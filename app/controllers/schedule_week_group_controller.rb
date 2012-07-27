# encoding: utf-8

require "base_controller"

#
# 週次のグループスケジューラのTOP画面を表示するController
# Sessionの初期化処理は行わない
#
class ScheduleWeekGroupController < BaseController::HtmlController
  def index
      exeption_handler do
        @group_resource_id = params[:group_resource_id]
      end
  end
end
