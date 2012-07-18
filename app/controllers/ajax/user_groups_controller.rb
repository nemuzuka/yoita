# encoding: utf-8

module Ajax #:nodoc:
  #
  # ユーザグループ管理のAjaxに関するController
  #
  class UserGroupsController < Ajax::AdminAjaxCommonController
    protected
      #
      # 使用Serviceインスタンス取得
      # ==== _Return_
      # 使用Serviceインスタンス
      #
      def get_service
        UserGroupsService.new
      end

      #
      # ページングjs関数名取得
      # ==== _Return_
      # ページングjs関数名
      #
      def get_function_name
        return "turnUserGroups"
      end

      #
      # ページングpath取得
      # ==== _Return_
      # ページングpath
      #
      def get_app_path
        return "/ajax/userGroups/turn"
      end
  end
end
