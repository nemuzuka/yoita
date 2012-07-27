# encoding: utf-8

module Ajax #:nodoc:

  #
  # グループ週次スケジュールのAjax
  #
  class ScheduleWeekGroupController < Ajax::ScheduleWeekController

    #
    # スケジュールデータ取得.
    # リクエストパラメータのグループリソースIDより、表示対象のリソース群を確定し、
    # 表示対象のスケジュールデータを1週間分取得します。
    #
    def index
      exeption_handler do

        group_resource_id = params[:group_resource_id]
        if group_resource_id.to_s == ''
          # 未指定の場合、デフォルトユーザグループ
          group_resource_id = get_user_info.default_user_group
          # デフォルトユーザグループが未設定の場合、全てのユーザ
          group_resource_id = FixGroupResourceIds::ALL_USERS if group_resource_id == nil
        end
        
        # Sessionに設定する
        group_search_param = ScheduleService::SearchParam.new
        group_search_param.group_resource_id = group_resource_id
        group_search_param.per = get_user_info.per_page
        get_schedule_dto.group_search_param = group_search_param
        
        # 基準日が空の場合、システム日付を基準日とする
        get_schedule_dto.base_date = ApplicationHelper::get_current_date if get_schedule_dto.base_date == nil
        # 1ページ目を設定
        group_search_param.page = 1
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
    # スケジュールデータ再描画.
    # Sessionに格納されている基準日を元に、スケジュールデータを再描画します
    #
    def refresh
      exeption_handler do
        write_response
      end
    end

    #
    # ページング処理.
    # 入力されたページ番号に対して、
    # Sessionに格納された検索条件を元に、検索し、
    # 検索条件に合致するデータを取得します。
    #
    def turn
      exeption_handler do
        page = params[:page_no]
        get_schedule_dto.group_search_param.page = page.to_i
        write_response
      end
    end
    
    private
      #
      # スケジュールデータレスポンス書き込み
      # 対象日から1週間分のスケジュールデータをレスポンスに書き込みます
      #
      def write_response

        # Session上に存在しない場合の措置
        group_search_param = get_schedule_dto.group_search_param
        group_search_param = ScheduleService::SearchParam.new if group_search_param == nil
        if group_search_param.group_resource_id == nil
          group_search_param.group_resource_id = FixGroupResourceIds::ALL_USERS
        end
        group_search_param.page = 1 if group_search_param.page == nil
        group_search_param.per = get_user_info.per_page if group_search_param.per == nil
        get_schedule_dto.group_search_param = group_search_param
        
        if get_schedule_dto.base_date == nil
          get_schedule_dto.base_date = ApplicationHelper::get_current_date
        end
        
        resource_id = get_user_info.resource_id
        service = ScheduleService.new
        result = service.create_group_schedule_view_week(
          get_schedule_dto.base_date, group_search_param, resource_id)
        
        json_result = Entity::JsonResult.new
        json_result.result = result

        render json: json_result
      end
  end

end
