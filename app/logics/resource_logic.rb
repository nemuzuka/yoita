#
# リソースに対するLogic
#
class ResourceLogic

  #
  # リソース登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   リソース登録・更新情報
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
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
  def save(params, resource_type, action_resource_id)
    
    resource = nil
    id = params[:resource][:id]
    
    if id == nil || id == ""
      # 新規登録の場合
      resource = Resource.new(params[:resource])
      resource[:sort_num] = MAX_LONG
      resource[:entry_resource_id] = action_resource_id
      resource[:resource_type] = resource_type
      resource[:update_resource_id] = action_resource_id
      
      if !resource.save
        # エラーが存在するので、例外をthrow
        raise CustomException::ValidationException.new(resource.errors.full_messages)
      end
      
    else
      # 更新の場合
      resource = get_resource(id, resource_type)
      
      # 更新するカラムを指定して、更新を行う
      clone_pamam = params[:resource].clone
      clone_pamam[:update_resource_id] = action_resource_id
      
      begin
        # 指定カラムに対して更新処理実行
        result = resource.update_attributes(
              clone_pamam.slice(:lock_version, :memo, :name, :update_resource_id))

        if result == false
          # エラーが存在するので、例外をthrow
          raise CustomException::ValidationException.new(resource.errors.full_messages)
        end
      rescue ActiveRecord::StaleObjectError
        # lock_versionが不正の場合、バージョンエラーのExceptionをthrow
        raise CustomException::InvalidVersionException.new
      end
    end
    return resource
  end
  
  #
  # リソース削除
  # 指定データを削除します。
  # ==== _Args_
  # [id]
  #   削除対象のリソースID
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
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
  def delete(id, resource_type, lock_version)
    # 更新の場合
    resource = get_resource(id, resource_type)
    resource[:lock_version] = lock_version
    begin
      # destroyでないとバージョンNoを参照しない
      resource.destroy
    rescue ActiveRecord::StaleObjectError
      # lock_versionが不正の場合、該当レコード無しのExceptionをthrow
      raise CustomException::InvalidVersionException.new
    end
  end

  #
  # リソース取得
  # idに紐付くリソース情報を取得します。
  # ==== _Args_
  # [id]
  #   取得対象のリソースID
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  # ==== _Raise_
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id, resource_type)
    resource = Resource.find_by_id(id)
    if resource == nil
      # 該当レコード無しのExceptionをthrow
      raise CustomException::NotFoundException.new
    end
    if resource[:resource_type] != resource_type
      # 更新前と更新後でリソース区分が異なる場合、Exceptionをthrow
      raise CustomException::IllegalParameterException.new
    end
    return resource
  end
  
  #
  # リソース検索
  # 検索条件に合致するリソース一覧を取得します
  # ==== _Args_
  # [params]
  #   検索条件(see. <i>ResourceSearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def find_by_conditions(params)
    Resource.find_by_conditions(params)
  end
  
  #
  # リソースソート順更新
  # 指定したidのソート順を変更します
  # ==== _Args_
  # [ids]
  #   更新対象idList。この順番にソート順を1から採番します
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  #
  def update_sort_num(ids, resource_type)
    Resource.update_sort_num(ids, resource_type)
  end
  
end