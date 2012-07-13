# encoding: utf-8
require "constants"
require "service"

#
# 設備グループに対するService
#
class FacilityGroupsService < Service::Base
  
  #
  # 設備グループ検索
  # 検索条件に合致する設備一覧を取得します
  # ==== _Args_
  # [params]
  #   検索条件(see. <i>ResourceSearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_conditions(params)
    transaction_handler do
      params.resource_type = ResourceType::FACILITY_GROUP
      logic = ResourceLogic.new
      logic.find_by_conditions(params)
    end
  end

  #
  # 設備グループ情報取得
  # 引数のidに紐付く設備グループを取得します
  # ==== _Args_
  # [id]
  #   取得対象id(空文字 or nullの場合、新規とみなす)
  # ==== _Return_
  # 該当レコード(see. <i>FacilityGroupsService::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id)
    transaction_handler do
      
      group_detail = nil
      if id.to_s != ""
        logic = GroupLogic.new
        group_detail = logic.get_resource(id, ResourceType::FACILITY_GROUP, false)
      else
        group_detail = GroupLogic::Detail.new
        group_detail.resource = Resource.new
        group_detail.resource_conn_list = []
      end
      
      result = FacilityGroupsService::Detail.new
      result.detail = group_detail
      
      # 設定されている全設備を設定
      result.facilities_list = create_all_faciliries
      return result
    end
  end
  
  #
  # 設備グループ登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   設備グループ登録・更新情報
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Raise_
  # [CustomException::ValidationException]
  #   validate時の例外
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合(更新時)
  #
  def save(params, action_resource_id)
    transaction_handler do
      logic = GroupLogic.new
      logic.save(params, ResourceType::FACILITY_GROUP, action_resource_id)
    end
  end
  
  #
  # 設備グループ削除
  # 指定設備グループを削除します。
  # ==== _Args_
  # [id]
  #   削除対象設備グループのリソースID
  # [lock_version]
  #   対象バージョンNo
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合
  # 
  def delete(id, lock_version)
    transaction_handler do
      logic = GroupLogic.new
      logic.delete(id, ResourceType::FACILITY_GROUP, lock_version)
    end
  end
  
  #
  # 設備グループソート順更新
  # 指定した設備グループのソート順を変更します
  # ==== _Args_
  # [ids]
  #   更新対象idList。この順番にソート順を1から採番します
  #
  def update_sort_num(ids)
    transaction_handler do
      logic = ResourceLogic.new
      logic.update_sort_num(ids, ResourceType::FACILITY_GROUP)
    end
  end
  
  #
  # 詳細データ
  #
  class Detail
    # 詳細データ(see. <i>GroupLogic::Detail</i>)
    attr_accessor :detail

    # 全設備情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :facilities_list
  end
  
  private
  
    #
    # 全設備情報取得
    # 登録されている全ての設備情報を取得します
    # ==== _Return_
    # 該当レコード(存在しない場合、size=0のList) <i>Entity::LabelValueBean</i>のlist
    #
    def create_all_faciliries
      params = ResourceSearchParam.new
      params.resource_type = ResourceType::FACILITY
      logic = ResourceLogic.new
      list = logic.find_by_conditions(params)
      
      result_list = []
      list.each do |target|
        result_list.push(Entity::LabelValueBean.new(target.id, target.name))
      end

      return result_list
    end
  
end
