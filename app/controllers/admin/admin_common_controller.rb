# encoding: utf-8

require "base_controller"

module Admin #:nodoc:

  #
  # 管理者機能の共通Contoroller.
  # ユーザ
  # 設備
  # ユーザグループ
  # 設備グループ
  # の管理機能はこれでカバーできます
  #
  class AdminCommonController < BaseController::HtmlController
    #
    # TOP画面を表示します
    #
    def index
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        user_info = get_user_info

        # 検索条件の初期値を設定
        search_param = create_search_param
        # 1ページあたりの表示件数設定
        search_param.per = user_info.per_page
        
        # Sessionに格納する
        re_create_session(user_info)
        session[get_search_param_symble] = search_param
      end
    end
    
    protected
      # 必要に応じて継承先で変更します
    
      #
      # 検索条件格納インスタンス取得
      # ==== _Return_
      # 検索条件格納インスタンス
      #
      def create_search_param
        return Resource::SearchParam.new
      end
      
      #
      # 検索条件格納インスタンスSession格納シンボル取得
      # ==== _Return_
      # 検索条件格納インスタンスSession格納シンボル
      #
      def get_search_param_symble
        return :resource_search_param
      end
    
  end
end
