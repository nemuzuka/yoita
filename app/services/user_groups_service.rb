# encoding: utf-8
require "constants"
require "service"

#
# ユーザグループに対するService
#
class UserGroupsService < Service::Base
  
  #
  # ユーザグループ検索
  # 検索条件に合致する設備一覧を取得します
  # ==== _Args_
  # [params]
  #   検索条件(see. <i>Resource::SearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_conditions(params)
    transaction_handler do
      params.resource_type = ResourceType::USER_GROUP
      logic = ResourceLogic.new
      logic.find_by_conditions(params)
    end
  end

  #
  # ユーザグループ情報取得
  # 引数のidに紐付くユーザグループを取得します
  # ==== _Args_
  # [id]
  #   取得対象id(空文字 or nullの場合、新規とみなす)
  # ==== _Return_
  # 該当レコード(see. <i>UserGroupsService::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id)
    transaction_handler do
      
      logic = GroupLogic.new
      group_detail = logic.get_resource(id, ResourceType::USER_GROUP, false)
       
      result = UserGroupsService::Detail.new
      result.detail = group_detail
      
      # 設定されている全設備を設定
      result.user_infos_list = create_all_faciliries
      return result
    end
  end
  
  #
  # ユーザグループ登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   ユーザグループ登録・更新情報
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
      logic.save(params, ResourceType::USER_GROUP, action_resource_id)
    end
  end
  
  #
  # ユーザグループ削除
  # 指定ユーザグループを削除します。
  # ==== _Args_
  # [id]
  #   削除対象ユーザグループのリソースID
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
      logic.delete(id, ResourceType::USER_GROUP, lock_version)
    end
  end
  
  #
  # ユーザグループソート順更新
  # 指定したユーザグループのソート順を変更します
  # ==== _Args_
  # [ids]
  #   更新対象idList。この順番にソート順を1から採番します
  #
  def update_sort_num(ids)
    transaction_handler do
      logic = ResourceLogic.new
      logic.update_sort_num(ids, ResourceType::USER_GROUP)
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
    attr_accessor :user_infos_list
  end
  
  private
  
    #
    # 全ユーザ情報取得
    # 登録されている全てのユーザ情報を取得します
    # ==== _Return_
    # 該当レコード(存在しない場合、size=0のList) <i>Entity::LabelValueBean</i>のlist
    #
    def create_all_faciliries
      params = Resource::SearchParam.new
      params.resource_type = ResourceType::USER
      logic = ResourceLogic.new
      list = logic.find_by_conditions(params)
      
      result_list = []
      list.each do |target|
        result_list.push(Entity::LabelValueBean.new(target.id, target.name))
      end

      return result_list
    end
  
end
