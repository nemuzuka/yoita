# encoding: utf-8

module Ajax #:nodoc:
  
  #
  # 週次スケジュール共通部分のAjax
  #
  class ScheduleWeekController < BaseController::JsonController
    
    #
    # スケジュール表示情報取得
    # Session上に格納しているスケジュール情報を取得します
    # ==== _Return_
    # スケジュール表示情報
    # see. <i></i>
    #
    def get_schedule_dto
      schedule_dto =  session[:schedule_dto]
      if schedule_dto == nil
        schedule_dto = Ajax::ScheduleWeekController::ScheduleDto.new
        session[:schedule_dto] = schedule_dto
      end

      return schedule_dto
    end
    
    #
    # 基準日算出.
    # リクエストパラメータの情報より基準日を算出します
    # 表示方法が「today」の場合、システム日付
    # 「next」の場合、基準日＋増加分日数
    # 「prev」の場合、基準日－減少日数
    # 日付指定されている場合、強制的に基準日を設定します
    # ==== _Return_
    # 基準日
    #
    def calc_base_date

      appointment_date = params[:appointment_date]
      if appointment_date.to_s != ''
        # 日付指定の場合、その日付が対象日
        return Date.strptime(appointment_date, "%Y/%m/%d")
      end

      add_type = 0
      target_date = nil
      case params[:view_type]
      when ViewType::NEXT
        target_date = get_schedule_dto.base_date
        add_type = 1
      when ViewType::PREV
        target_date = get_schedule_dto.base_date
        add_type = -1
      end
      
      target_date = ApplicationHelper::get_current_date if target_date == nil
      
      amount = 0
      case params[:amount_type]
      when AmountType::DAY
        amount = 1
      when AmountType::WEEK
        amount = 7
      end

      if amount != 0
        # 基準日から日付を移動
        target_date = target_date + (amount * add_type)
      end

      return target_date
    end
    
    #
    # スケジュール表示条件
    #
    class ScheduleDto
      # 基準日
      attr_accessor :base_date

      # グループ指定条件
      # <i>ScheduleService::SearchParam</i>
      attr_accessor :group_search_param
      
    end
  end
end
