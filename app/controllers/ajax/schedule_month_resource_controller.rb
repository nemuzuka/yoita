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
    def move_month
      exeption_handler do
        search_param = get_search_param
        
        # 表示対象の年月を算出して、スケジュール表示
        view_type = params[:view_type]
        target_month = nil
        case view_type
        when ViewType::TODAY
          target_month = ApplicationHelper::get_current_date.strftime("%Y%m")
        when ViewType::NEXT
          target_month = DateHelper::add_month(search_param.target_month, 1)
        when ViewType::PREV
          target_month = DateHelper::add_month(search_param.target_month, -1)
        end
        search_param.target_month = target_month

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
        search_param = get_search_param
        
        service = ScheduleService.new
        result = service.create_resource_schedule_view_month(
          search_param.target_month, search_param.resource_id, 
          get_user_info.resource_id)
        
        json_result = Entity::JsonResult.new
        json_result.result = result

        render json: json_result
      end
      
      #
      # 検索条件取得
      # Sessionに存在しない場合、初期値を設定します
      #
      def get_search_param
        search_param = session[:schedule_month_dto]
        if search_param == nil
          search_param = Ajax::ScheduleMonthResourceController::ScheduleDto.new
          search_param.target_month = 
            ApplicationHelper::get_current_date.strftime("%Y%m")
          search_param.resource_id = get_user_info.resource_id
          session[:schedule_month_dto] = search_param
        end
        return search_param
      end
      
  end

end
