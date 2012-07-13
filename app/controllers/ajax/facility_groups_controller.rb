# encoding: utf-8

module Ajax #:nodoc:
  #
  # 設備グループ管理のAjaxに関するController
  #
  class FacilityGroupsController < Ajax::AdminAjaxCommonController
    protected
      #
      # 使用Serviceインスタンス取得
      # ==== _Return_
      # 使用Serviceインスタンス
      #
      def get_service
        FacilityGroupsService.new
      end

      #
      # ページングjs関数名取得
      # ==== _Return_
      # ページングjs関数名
      #
      def get_function_name
        return "turnFacilityGroups"
      end

      #
      # ページングpath取得
      # ==== _Return_
      # ページングpath
      #
      def get_app_path
        return "/ajax/facilityGroups/turn"
      end
  end
end
