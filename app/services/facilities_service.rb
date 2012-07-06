#
# 設備に対するService
#
class FacilitiesService < Service::Base
  
  #
  # 設備検索
  # 検索条件に合致する設備一覧を取得します
  # ==== _Args_
  # [params]
  #   検索条件(see. <i>ResourceSearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_conditions(params)
    transaction_handler do
      params.resource_type = ResourceType::FACILITY
      logic = ResourceLogic.new
      logic.find_by_conditions(params)
    end
  end

  #
  # 設備情報取得
  # 引数のidに紐付く設備を取得します
  # ==== _Args_
  # [id]
  #   取得対象id
  # ==== _Return_
  # 該当レコード
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id)
    transaction_handler do
      logic = ResourceLogic.new
      logic.get_resource(id, ResourceType::FACILITY)
    end
  end
  
  #
  # 設備登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   設備登録・更新情報
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Raise_
  # [CustomException::ValidationException]
  #   validate時の例外
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def save(params, action_resource_id)
    transaction_handler do
      logic = ResourceLogic.new
      logic.save(params, ResourceType::FACILITY, action_resource_id)
    end
  end
  
  #
  # 設備削除
  # 指定設備を削除します。
  # ==== _Args_
  # [id]
  #   削除対象設備のリソースID
  # [lock_version]
  #   対象バージョンNo
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # 
  def delete(id, lock_version)
    transaction_handler do
      logic = ResourceLogic.new
      logic.delete(id, ResourceType::FACILITY, lock_version)
    end
  end
  
  #
  # 設備ソート順更新
  # 指定した設備のソート順を変更します
  # ==== _Args_
  # [ids]
  #   更新対象idList。この順番にソート順を1から採番します
  #
  def update_sort_num(ids)
    transaction_handler do
      logic = ResourceLogic.new
      logic.update_sort_num(ids, ResourceType::FACILITY)
    end
  end
  
end
