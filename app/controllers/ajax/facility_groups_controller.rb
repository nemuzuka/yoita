# encoding: utf-8
require "resource_search_param"

module Ajax #:nodoc:
  #
  # 設備グループ管理のAjaxに関するController
  #
  class FacilityGroupsController < Ajax::AdminAjaxCommonController
    protected
      def get_service
        FacilityGroupsService.new
      end
  end
end
