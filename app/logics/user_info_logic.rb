# encoding: utf-8
require "constants"
require 'digest/sha2'

#
# ユーザ情報に対するLogic
#
class UserInfoLogic
  
  #
  # ユーザ情報登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   ユーザ登録・更新情報
  # [resource_type]
  #   リソース区分(see. <i>ResourceType</i>)
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Return_
  # 処理リソースレコード
  # ==== _Raise_
  # [CustomException::ValidationException]
  #   validate時の例外
  # [CustomException::IllegalParameterException]
  #   不正なパラメータを渡された場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::UniqueConstraintException]
  #   既に登録されているログインIDの場合(登録時)
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合(更新時)
  #
  def save(params, resource_type, action_resource_id)
    
    # 共通validate
    common_validate(params)

    # リソース情報を登録・更新
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, resource_type, action_resource_id)

    id = params[:resource][:id]
    if id.to_s == ''
      # 新規登録の場合
      insert_validate(params)

      # ユーザ情報の登録
      user_info = UserInfo.new(params[:user_info])
      user_info[:resource_id] = resource.id
      user_info[:entry_resource_id] = action_resource_id
      user_info[:update_resource_id] = action_resource_id
      
      begin
        user_info.save!
      rescue ActiveRecord::RecordInvalid => e
        raise CustomException::ValidationException.new(e.record.errors.full_messages)
      end
      
      # 認証情報の登録
      login = Login.new
      login[:login_id] = params[:login][:login_id]
      login[:password] = Digest::SHA512.hexdigest(params[:login][:password])
      login[:resource_id] = resource.id
      login[:entry_resource_id] = action_resource_id
      login[:update_resource_id] = action_resource_id
      begin
        login.save!
      rescue ActiveRecord::RecordNotUnique
        raise CustomException::UniqueConstraintException.new()
      rescue ActiveRecord::RecordInvalid => e
        raise CustomException::ValidationException.new(e.record.errors.full_messages)
      end

    else
      # 更新の場合
      
    end
    return resource
  end
  
  #
  # 詳細情報取得
  #
  def get_detail
    
  end
  
  #
  # 削除
  # ユーザグループからも削除します
  #
  def delete
    
  end
  
  private
    #
    # 登録・更新validate
    # 有効開始日の必須チェック
    # 有効終了日が空文字の場合、最大日付を設定する
    # 有効開始日 > 有効終了日の関係の場合、validateエラー
    def common_validate(params)
      if params[:user_info][:validity_start_date].to_s == ""
        raise CustomException::ValidationException.new(["有効開始日は必須です。"])
      end
      if params[:user_info][:validity_end_date].to_s == ""
        # 有効終了日が空の場合、最大日付を設定する
        params[:user_info][:validity_end_date] = MAX_DATE.strftime("%Y/%m/%d")
      end
      
      validity_start_date = Date.strptime(params[:user_info][:validity_start_date], "%Y/%m/%d")
      validity_end_date = Date.strptime(params[:user_info][:validity_end_date], "%Y/%m/%d")
      if validity_start_date > validity_end_date
        raise CustomException::ValidationException.new(["有効終了日は有効開始日以降の日付を指定して下さい。"])
      end
    end
    
    #
    # 登録validate
    # パスワードが未入力の場合
    # パスワードが入力されていても、6文字より少ない場合、エラー
    #
    def insert_validate(params)
      password = params[:login][:password]
      if password.to_s == ''
        raise CustomException::ValidationException.new(["パスワードは必須です。"])
      end
      
      if password.length < 6
        raise CustomException::ValidationException.new(["パスワードは6文字以上設定して下さい。"])
      end
    end
  
end
