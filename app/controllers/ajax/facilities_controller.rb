# encoding: utf-8
require "resource_search_param"

module Ajax #:nodoc:
  #
  # 設備管理のAjaxに関するController
  #
  class FacilitiesController < AdminAjaxCommonController
    protected
      def get_service
        FacilitiesService.new
      end
  end
end
