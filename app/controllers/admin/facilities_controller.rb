# encoding: utf-8

require "base_controller"
require "resource_search_param"

module Admin
  #
  # 設備管理に関するController
  #
  class FacilitiesController < BaseController::HtmlController
    
    #
    # TOP画面を表示します
    #
    def index
      exeption_handler do
        user_info = get_user_info

        # 検索条件の初期値を設定
        search_param = ResourceSearchParam.new
        # 1ページあたりの表示件数設定
        search_param.per = user_info.per_page
        
        # Sessionに格納する
        re_create_session(user_info)
        session[:resource_search_param] = search_param
      end
    end
  
  end
  
end
