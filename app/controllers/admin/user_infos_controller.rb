# encoding: utf-8

module Admin #:nodoc:
  #
  # ユーザ管理に関するController
  #
  class UserInfosController < Admin::AdminCommonController
    protected
      #
      # 検索条件格納インスタンス取得
      # ==== _Return_
      # 検索条件格納インスタンス
      #
      def create_search_param
        return UserInfo::SearchParam.new
      end
      
      #
      # 検索条件格納インスタンスSession格納シンボル取得
      # ==== _Return_
      # 検索条件格納インスタンスSession格納シンボル
      #
      def get_search_param_symble
        return :user_info_search_param
      end
  end
  
end
