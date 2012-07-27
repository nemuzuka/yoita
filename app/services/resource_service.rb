# encoding: utf-8
require "constants"
require "service"

#
# リソースに対するService
#
class ResourceService < Service::Base
  
  #
  # リソース情報取得
  # ==== _Args_
  # [resource_id]
  #   リソースID
  # ==== _Return_
  # 該当データ(see. <i>ResourceService::Detail</i>)
  #
  def get_detail(resource_id)
    resource_logic = ResourceLogic.new
    search_param = Resource::SearchParam.new
    search_param.ids = [resource_id]
    list = resource_logic.find_by_conditions(search_param)
    if list.length != 1
      raise CustomException::NotFoundException.new
    end
    resource = list[0]
    detail = ResourceService::Detail.new
    detail.resource = resource
    
    group_logic = GroupLogic.new
    # 取得したリソースによって、処理を仕分ける
    case resource[:resource_type]
    when ResourceType::USER
      user_info_logic = UserInfoLogic.new
      user_detail = user_info_logic.get_detail(resource_id)
      detail.user_info = user_detail.user_info
      detail.belong_group_list = group_logic.create_group_list(resource_id)
    when ResourceType::FACILITY
      detail.belong_group_list = group_logic.create_group_list(resource_id)
    end
    return detail
  end
  
  #
  # リソース詳細データ
  #
  class Detail
    # リソース
    attr_accessor :resource
    
    # ユーザ情報(リソースがユーザの場合)
    attr_accessor :user_info
    
    # 所属グループ(リソースがユーザ or 設備の場合)
    # <i>Entity::LabelValueBean</i>のList
    attr_accessor :belong_group_list
    
  end
end
