# encoding: utf-8

module Ajax #:nodoc:

  #
  # スケジュールダイアログのAjax
  #
  class ScheduleController < BaseController::JsonController

    #
    # スケジュール詳細データ取得.
    #
    def get_info
      exeption_handler do
        
        schedule_id = params[:schedule_id]
        target_date = params[:target_date]
        target_resource_id = params[:selected_resource_id]

        service = ScheduleDetailService.new
        result = service.get_detail(schedule_id, target_date, target_resource_id, get_user_info)        
        
        ajax_result = Entity::JsonResult.new
        ajax_result.result = result
        render json: ajax_result
      end
    end
    
    #
    # スケジュール登録・更新
    #
    def save
      exeption_handler do
        # リクエストパラメータを元に登録・更新
        service = ScheduleService.new
        service.save(params, get_user_info.resource_id)
        
        result = Entity::JsonResult.new
        result.info_msgs.push("正常に終了しました");
        render json: result
        
      end
    end
    
  end

end
