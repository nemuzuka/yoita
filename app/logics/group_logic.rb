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
  # idが未設定の場合、newしただけのインスタンスを返します。
  # idが設定されていても該当データが存在しない場合、例外をthrowします
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
    
    result = GroupLogic::Detail.new
    if id.to_s == ''
        result = GroupLogic::Detail.new
        result.resource = Resource.new
        result.resource_conn_list = []
        return result
    end
    
    logic = ResourceLogic.new
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
  # ユーザ・設備グループ削除
  # idに紐付くリソース情報を削除します。
  # 自身が親になっているグループ関連データを削除します。
  # ==== _Args_
  # [id]
  #   取得対象のリソースID
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  # [lock_version]
  #   バージョンNo
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def delete(id, resource_type, lock_version)
    logic = ResourceLogic.new
    logic.delete(id, resource_type, lock_version)
    # リソースidが親となっている関連を削除
    UserFacilitiesGroupConn.delete_by_parent_id(id)
  end
  
  #
  # グループに紐付くリソース情報取得
  # 指定したグループに紐付くリソース情報を全て取得し、
  # 指定されたページに表示する分のListを作成します
  # 取得したリソースListの中に、自分のリソースIDが存在する場合、0番目のindexに自分を移動します
  # ==== _Args_
  # [resource_id]
  #   指定グループのリソースID
  # [self_resource_id]
  #   ログインユーザのリソースID
  # [pager_condition]
  #   ページリンク生成条件。<i>SqlHelper::DefaultPagerCondition</i>のサブクラスのインスタンスである必要があります。
  # ==== _Return_
  # 指定ページに表示するリソースIDのList
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # 
  #
  def get_group_resources(resource_id, self_resource_id, pager_condition)
    # 指定グループに紐付くリソース一覧を取得
    resource_conn_list = get_group_resource_list(resource_id, true)

    pager_condition.total_count = "0"
    pager_condition.total_count = resource_conn_list.length.to_s
    resource_all_list = []
    resource_conn_list.each do |target|
      if target.key.to_s == self_resource_id.to_s
        # 自分のリソースIDが存在する場合、先頭に移動
        resource_all_list.unshift(target.key)
      else
        resource_all_list.push(target.key)
      end
    end
    
    # 指定ページに紐付くListだけを抽出
    PagerHelper::create_slice_list(pager_condition, resource_all_list)
    
  end

  #
  # グループリソース情報取得
  # ==== _Args_
  # [resource_id]
  #   指定グループのリソースID
  # [include_parent]
  #   戻り値に親リソースIDが子リソースIDのものを含める場合、true(ユーザグループの場合のみ有効)
  # ==== _Return_
  # グループに紐付くリソースList
  # <i>Entity::LabelValueBean</i>のlist
  #
  def get_group_resource_list(resource_id, include_parent)
    # 指定されたリソースに紐付くデータを取得
    search_param = Resource::SearchParam.new
    search_param.ids = [resource_id]
    resource_logic = ResourceLogic.new
    resource_list = resource_logic.find_by_conditions(search_param)
    if resource_list.length != 1
      return []
    end
    target_group_resource = resource_list[0]
    # 指定リソースがユーザグループ or 設備グループでない場合、不正なリクエストとする
    case target_group_resource[:resource_type]
    when ResourceType::USER_GROUP, ResourceType::FACILITY_GROUP
    else
      raise CustomException::IllegalParameterException.new
    end
    
    # 該当グループに紐付くデータを取得
    detail = get_resource(
      target_group_resource[:id], target_group_resource[:resource_type], include_parent)
    return detail.resource_conn_list
  end
    
  #
  # 固定グループに紐付くリソース情報取得.
  # 指定した固定グループに紐付くリソース情報を取得します
  # 取得したリソースListの中に、自分のリソースIDが存在する場合、0番目のindexに自分を移動します
  # ==== _Args_
  # [fix_group_resource_id]
  #   固定グループのリソースID(see. <i>FixGroupResourceIds</i>)
  # [self_resource_id]
  #   ログインユーザのリソースID
  # [pager_condition]
  #   ページリンク生成条件。<i>SqlHelper::DefaultPagerCondition</i>のサブクラスのインスタンスである必要があります。
  # ==== _Return_
  # 指定ページに表示するリソースIDのList
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  #
  def get_fix_group_resources(fix_group_resource_id, self_resource_id, pager_condition)
    
    list = get_fix_group_resource_list(fix_group_resource_id) 
       
    pager_condition.total_count = "0"
    pager_condition.total_count = list.length.to_s
    
    # 戻り値のデータを生成
    resource_all_list = []
    list.each do |target|
      if target[:id].to_s == self_resource_id.to_s
        # 自分のリソースIDが存在する場合、先頭に移動
        resource_all_list.unshift(target[:id])
      else
        resource_all_list.push(target[:id])
      end
    end
    
    # 指定ページに紐付くListだけを抽出
    PagerHelper::create_slice_list(pager_condition, resource_all_list)
  end

  #
  # 固定グループリソース情報取得
  # ==== _Args_
  # [fix_group_resource_id]
  #   固定グループのリソースID(see. <i>FixGroupResourceIds</i>)
  # ==== _Return_
  # 該当する<i>Resource</i>のlist
  #
  def get_fix_group_resource_list(fix_group_resource_id)
    
    search_param = Resource::SearchParam.new
    case fix_group_resource_id.to_i
    when FixGroupResourceIds::ALL_USERS
      search_param.resource_type = ResourceType::USER
    when FixGroupResourceIds::ALL_FACILITIES
      search_param.resource_type = ResourceType::FACILITY
    when FixGroupResourceIds::ALL_USER_GROUP
      search_param.resource_type = ResourceType::USER_GROUP
    else
      raise CustomException::IllegalParameterException.new
    end
    
    logic = ResourceLogic.new
    return logic.find_by_conditions(search_param)
  end

  
  #
  # 全ユーザグループListを作成します
  # index:0のデータは、空行を付与します
  # ==== _Return_
  # 全ユーザグループ情報。<i>Entity::LabelValueBean</i>のlist
  #
  def create_all_user_group
    ret_list = []
    logic = ResourceLogic.new
    search_param = Resource::SearchParam.new
    search_param.resource_type = ResourceType::USER_GROUP
    user_group_list = logic.find_by_conditions(search_param)
    LabelValueBeanHelper::add_group(ret_list, user_group_list)
    return ret_list
  end
  
  #
  # 全設備グループListを作成します
  # index:0のデータは、空行を付与します
  # ==== _Return_
  # 全設備グループ情報。<i>Entity::LabelValueBean</i>のlist
  #
  def create_all_facility_group
    ret_list = []
    logic = ResourceLogic.new
    search_param = Resource::SearchParam.new
    search_param.resource_type = ResourceType::FACILITY_GROUP
    facility_group_list = logic.find_by_conditions(search_param)
    LabelValueBeanHelper::add_group(ret_list, facility_group_list)
    return ret_list
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
      
      resource_search_param = Resource::SearchParam.new
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
      else
        raise CustomException::IllegalParameterException.new
      end
      
      return type
    end
  
end

