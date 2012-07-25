# encoding: utf-8

module Ajax #:nodoc:

  #
  # ログインユーザ週次スケジュールのAjax
  #
  class ScheduleWeekUserController < Ajax::ScheduleWeekController

    #
    # スケジュールデータ取得.
    # リクエストパラメータの表示方法、日付指定方法によって対象日を算出し、
    # 表示対象のスケジュールデータを1週間分取得します。
    #
    def index
      exeption_handler do
        target_date = calc_base_date
        get_schedule_dto.base_date = target_date
        write_response(target_date)
      end
    end
    
    private
      #
      # スケジュールデータレスポンス書き込み
      # 対象日から1週間分のスケジュールデータをレスポンスに書き込みます
      # ==== _Args_
      # [target_date]
      #   表示対象日付
      #
      def write_response(target_date)
        resource_id = get_user_info.resource_id
        service = ScheduleService.new
        result = service.create_resource_schedule_view_week(target_date, resource_id, resource_id)
        
        json_result = Entity::JsonResult.new
        json_result.result = result

        render json: json_result
      end
  end

end
