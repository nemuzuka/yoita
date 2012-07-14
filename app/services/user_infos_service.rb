# encoding: utf-8
require "constants"
require "service"

#
# ユーザに対するService
#
class UserInfosService < Service::Base
  
  #
  # ユーザ検索
  # 検索条件に合致するユーザ一覧を取得します
  # ==== _Args_
  # [params]
  #   検索条件(see. <i>UserInfo::SearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_conditions(params)
    transaction_handler do
      logic = UserInfoLogic.new
      logic.find_by_conditions(params)
    end
  end

  #
  # ユーザ詳細情報取得
  # 引数のidに紐付くユーザを取得します
  # ==== _Args_
  # [id]
  #   取得対象id(空文字 or nullの場合、新規とみなす)
  # ==== _Return_
  # 該当レコード(see. <i>UserInfoLogic::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id)
    transaction_handler do
      
      logic = UserInfoLogic.new
      logic.get_detail(id)

    end
  end
  
  #
  # ユーザ登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   ユーザ登録・更新情報
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
      logic = UserInfoLogic.new
      logic.save(params, ResourceType::USER, action_resource_id)
    end
  end
  
  #
  # ユーザ削除
  # ユーザを削除します。
  # ==== _Args_
  # [params]
  #   ユーザ削除情報
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合
  # 
  def delete(params)
    transaction_handler do
      logic = UserInfoLogic.new
      logic.delete(params)
    end
  end
  
  #
  # ユーザソート順更新
  # 指定したユーザのソート順を変更します
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
  
end
