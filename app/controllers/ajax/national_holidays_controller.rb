# encoding: utf-8

module Ajax #:nodoc:
  
  #
  # 祝日管理のAjaxに関するController
  #
  class NationalHolidaysController < BaseController::JsonController

    #
    # 登録情報取得
    # 指定された対象年に紐付く登録情報を取得します
    #
    def get_holidays_info
      exeption_handler do
        target_year = params[:target_year]
        service = NationalHolidaysService.new
        result = service.find_by_target_year(target_year)
        
        json_result = Entity::JsonResult.new
        json_result.result = result
        render json: json_result
      end
    end
    
    #
    # 登録
    # 指定された対象年に紐付く祝日情報を登録します
    #
    def update
      exeption_handler do
        target_year = params[:target_year]
        target_day_list = params[:target_day_list]
        memo_list = params[:memo_list]
        service = NationalHolidaysService.new
        service.insert_holiday(target_year, target_day_list, memo_list)
        
        json_result = Entity::JsonResult.new
        json_result.info_msgs.push("正常に終了しました");
        render json: json_result
      end
    end
    
  end
end
