# encoding: utf-8
require "constants"

#
# ユーザ・設備グループに対するLogic
#
class GroupLogic
  
  #
  # ユーザ・設備グループ登録・更新
  # リソース情報を登録・更新した後、関連データを登録します
  # ==== _Args_
  # [params]
  #   リソース登録・更新情報
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Return_
  # 処理リソース
  # see. <i>ResourceLogic#save(params, resource_type, action_resource_id)</i>
  #
  def save(params, resource_type, action_resource_id)
    # リソース情報を登録・更新
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, resource_type, action_resource_id)
    
    # 処理対象のリソースidに紐付く情報を削除
    UserFacilitiesGroupConn.delete_by_parent_id(resource.id)
    # リクエストパラメータより子リソースIDを取得
    param_ids = params[:child_ids]
    
    # 子リソースIDを取得
    child_hash = create_exists_child_hash(
      param_ids, 
      get_search_child_type(resource_type), true)

    target_child_ids = []
    param_ids.each do |target|
      # リクエストパラメータのidが登録されていれば登録対象のidとする
      if child_hash.has_key?(target)
        target_child_ids.push(target)
      end
    end

    if resource_type == ResourceType::USER_GROUP
      # 登録対象のリソースIDの先頭に、ユーザグループ自信のリソースIDを付与する
      target_child_ids.unshift(resource.id)
    end
    
    # 子リソースIDを登録
    UserFacilitiesGroupConn.insert_child_list(resource.id, target_child_ids)

    return resource
  end
  
  #
  # リソース取得
  # idに紐付くリソース情報を取得します。
  # ==== _Args_
  # [id]
  #   取得対象のリソースID
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  # [include_parent]
  #   戻り値に親リソースIDが子リソースIDのものを含める場合、true(ユーザグループの場合のみ有効)
  # ==== _Return_
  # 該当レコード(see. <i>GroupLogic::Detail</i>)
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id, resource_type, include_parent)
    
    logic = ResourceLogic.new
    result = GroupLogic::Detail.new
    result.resource = logic.get_resource(id, resource_type)
    
    # 紐付く子リソース情報を取得
    list = UserFacilitiesGroupConn.find_by_parent_id(id, include_parent)
    ids = []
    list.each do |target|
      ids.push(target.child_resource_id)
    end
    # DBに登録されている値のみ取得する
    child_hash = create_exists_child_hash(
      ids, 
      get_search_child_type(resource_type), false)
    
    # ユーザグループで、かつ親の情報のものを含む場合、Hashに親の情報を追加
    if resource_type == ResourceType::USER_GROUP && include_parent == true
      child_hash[result.resource.id.to_s] = result.resource.name
    end
    
    # リソースとして登録されたデータのみ戻り値に設定する
    result.resource_conn_list = []
    list.each do |target|
      name = child_hash[target.child_resource_id.to_s]
      if name != nil
        label_value_bean = Entity::LabelValueBean.new(target.child_resource_id, name)
        result.resource_conn_list.push(label_value_bean)
      end
    end
    
    return result
  end
  
  #
  # 取得リソース戻り値.
  #
  class Detail
    # 該当リソース
    attr_accessor :resource
    # リソース構成情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :resource_conn_list
  end
  
  private
    #
    # 登録済みリソース情報取得
    # リソースIDとリソース区分が合致するリソース情報を取得します
    # 1件も有効なリソースが存在しない場合、例外をthrowします
    # ==== _Args_
    # [ids]
    #   取得対象リソースIDList
    # [resource_type]
    #   リソース区分(see. <i>ResourceType</i>)
    # [check]
    #   引数のリソースIDList or 有効なリソースが1件も存在しない場合、エラーとする場合、true
    # ==== _Return_
    # 該当ハッシュ(key:リソースID(文字列), value:名称)
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
    def create_exists_child_hash(ids, resource_type, check)
      
      if (ids == nil || ids.length == 0) && check == true
        raise CustomException::ValidationException.new(["参加リソースの選択は必須です"])
      end
      
      resource_search_param = ResourceSearchParam.new
      resource_search_param.ids = ids
      resource_search_param.resource_type = resource_type
      list = Resource.find_by_conditions(resource_search_param)
      
      result_hash = {}
      list.each do |target|
        result_hash[target.id.to_s] = target.name
      end

      # 指定リソースが1件も存在しない場合、例外をthrowする
      if result_hash.length == 0 && check == true
        raise CustomException::ValidationException.new(["有効な参加リソースが存在しません"])
      end
      
      return result_hash
    end
    
    #
    # 子リソース検索用Type取得
    # ユーザグループの場合、ユーザ
    # 設備グループの場合、設備
    # を検索するように返却します
    # ==== _Args_
    # [resource_type]
    #   ベースリソース区分
    # ==== _Return_
    # 検索対象リソース区分
    #
    def get_search_child_type(resource_type)
      # グループによって処理を分ける
      type = nil
      if resource_type == ResourceType::USER_GROUP
        # ユーザグループの場合、ユーザとして登録されているリソースIDのみ登録対象
        type = ResourceType::USER
      elsif resource_type == ResourceType::FACILITY_GROUP
        # 設備グループの場合、設備として登録されているリソースIDのみ登録対象
        type = ResourceType::FACILITY
      end
      
      return type
    end
  
end

