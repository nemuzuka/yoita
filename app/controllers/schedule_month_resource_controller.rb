# encoding: utf-8

require "base_controller"

#
# 月次のグループスケジューラのTOP画面を表示するController
# Sessionの初期化処理は行わない
#
class ScheduleMonthResourceController < BaseController::HtmlController
  def index
      exeption_handler do
        
        # Session上の表示情報より、表示対象年月を取得する
        base_date = nil
        schedule_dto =  session[:schedule_dto]
        if schedule_dto == nil
          base_date = ApplicationHelper::get_current_date
        else
          base_date = schedule_dto.base_date
        end
        target_month = base_date.strftime("%Y%m")
        
        schedule_month_dto = Ajax::ScheduleMonthResourceController::ScheduleDto.new
        schedule_month_dto.target_month = target_month
        schedule_month_dto.resource_id = params[:resource_id]
        session[:schedule_month_dto] = schedule_month_dto
      end
  end
end
