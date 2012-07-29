# encoding: utf-8

module Ajax #:nodoc:

  #
  # リソース月次スケジュールのAjax
  #
  class ScheduleMonthResourceController < BaseController::JsonController

    #
    # スケジュールデータ取得.
    # 対象年月のリソーススケジュールを1ヶ月分取得します。
    #
    def index
      exeption_handler do
        write_response
      end
    end

    #
    # 日付移動.
    # リクエストパラメータの日付指定に従って基準日を変更し、
    # 表示対象のスケジュールデータを1週間分取得します。
    #
    def move_date
      exeption_handler do

        target_date = calc_base_date
        get_schedule_dto.base_date = target_date
        write_response
      end
      
    end

    #
    # スケジュール表示条件
    #
    class ScheduleDto
      # 対象リソース
      attr_accessor :resource_id

      # 対象年月
      attr_accessor :target_month
    end
    
    private
      #
      # スケジュールデータレスポンス書き込み
      # 対象日から1週間分のスケジュールデータをレスポンスに書き込みます
      #
      def write_response

        # 検索条件をSessionより取得
        search_param = session[:schedule_month_dto]
        if search_param == nil
          search_param = Ajax::ScheduleMonthResourceController::ScheduleDto.new
          schedule_month_dto.target_month = 
            ApplicationHelper::get_current_date.strftime("%Y%m")
          schedule_month_dto.resource_id = get_user_info.resrouce_id
        end
        
        service = ScheduleService.new
        result = service.create_resource_schedule_view_month(
          search_param.target_month, schedule_month_dto.resource_id, 
          get_user_info.resrouce_id)
        
        json_result = Entity::JsonResult.new
        json_result.result = result

        render json: json_result
      end
  end

end
