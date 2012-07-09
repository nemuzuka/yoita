#
# 管理者用機能のModule
#
module Admin #:nodoc:

  #
  # 設備管理に関するController
  #
  class FacilitiesController < BaseController::HtmlController
    
    #
    # TOP画面を表示します
    #
    def index
      exeption_handler do
        # 検索条件の初期値を設定
        searchParam = ResourceSearchParam.new
        
        # 1ページあたりの表示件数は、
        # ログインユーザ情報から取得するようにいしたいけど、
        # まずは固定値
        searchParam.per = 3
        
        # Sessionに格納する
        user_info = super.get_user_info()
        super.re_create_session(user_info)
        session[:resource_search_param] = searchParam
        
        # 初期画面表示
        # TODO
        
      end
    end
  
  end
end
