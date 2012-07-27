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

    #
    # スケジュール削除
    #
    def delete
      exeption_handler do
        schedule_id = params[:schedule_id]
        lock_version = params[:lock_version]
        # リクエストパラメータを元に登録・更新
        service = ScheduleService.new
        service.delete(schedule_id, lock_version, get_user_info.resource_id)
        
        result = Entity::JsonResult.new
        result.info_msgs.push("正常に終了しました");
        render json: result
        
      end
    end
    
    #
    # 指定グループに紐付くリソース一覧情報取得
    #
    def get_group_conn_list
      exeption_handler do
        selected_group_resource = params[:selected_group_resource]
        # リクエストパラメータを元に登録・更新
        service = ScheduleDetailService.new
        result = service.create_group_conn_list(selected_group_resource, true)

        ajax_result = Entity::JsonResult.new
        ajax_result.result = result
        render json: ajax_result
        
      end
    end
    
    #
    # リソース詳細情報取得
    #
    def get_resource_detail
      exeption_handler do
        resource_id = params[:resource_id]
        # リクエストパラメータを元に登録・更新
        service = ResourceService.new
        result = service.get_detail(resource_id)

        ajax_result = Entity::JsonResult.new
        ajax_result.result = result
        p ajax_result
        render json: ajax_result
      end
    end
    
  end

end
