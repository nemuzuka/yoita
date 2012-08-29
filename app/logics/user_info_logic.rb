# encoding: utf-8
require "constants"
require 'digest/sha2'

#
# ユーザ情報に対するLogic
#
class UserInfoLogic
  
  #
  # ユーザ検索.
  # 各行に対して、有効期限内であるかを判断し、disableプロパティに追加します
  # 検索条件として設定されている項目に対してのみWhere句に設定します。ページャ用の設定がされている場合、ページング処理を行います
  # 複数テーブルを内部結合してSQL文を発行します
  # ==== _Args_
  # [param]
  #   検索条件パラメータ(see. <i>UserInfo::SearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  # record:SQLで取得したレコード
  # disable:無効の場合、true
  # をプロパティに持つHashのリスト
  #
  def find_by_conditions(params)
    list = UserInfo.find_by_conditions(params)
    
    # 有効期間を参照し、有効状態を付与する
    result_list = []
    search_base_date = params.search_base_date
    list.each do |target|
      disable_value = nil
      if target[:validity_start_date] <= search_base_date && 
          search_base_date <= target[:validity_end_date]
        disable_value = false
      else
        disable_value = true
      end
      result_list.push({:record => target, :disable => disable_value})
    end
    return result_list

  end
  
  #
  # ユーザ情報登録・更新
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   ユーザ登録・更新情報
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
  # [CustomException::UniqueConstraintException]
  #   既に登録されているログインIDの場合(登録時)
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合(更新時)
  #
  def save(params, action_resource_id)
    
    # 共通validate
    common_validate(params)

    # リソース情報を登録・更新
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, ResourceType::USER, action_resource_id)

    id = params[:resource][:id]
    if id.to_s == ''
      # 新規登録の場合
      validate_insert(params)

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
      login[:provider] = params[:login][:provider]
      if login[:provider].to_s == ''
        # 未設定の場合、アプリ認証
        login[:provider] = ProviderType::YOITA
      end
      begin
        login.save!
      rescue ActiveRecord::RecordNotUnique
        raise CustomException::UniqueConstraintException.new()
      rescue ActiveRecord::RecordInvalid => e
        raise CustomException::ValidationException.new(e.record.errors.full_messages)
      end

    else
      # 更新の場合
      validate_update(params)

      # ユーザ情報の更新
      update_user_info(id, params, action_resource_id)
      
      # login情報を更新
      update_login(id, params, action_resource_id)
    end
    return resource
  end
  
  #
  # 認証.
  # 入力されたユーザIDとパスワードが合致するloginsテーブルの情報を取得します
  # ==== _Args_
  # [login_id]
  #   ログインID
  # [password]
  #   パスワード
  # ==== _Return_
  # 該当レコード(存在しない場合、nil)
  #
  def auth(login_id, password)
    Login.auth(login_id, password)
  end

  #
  # 認証.
  # 入力されたユーザIDが合致するloginsテーブルの情報を取得します
  # Facebookで登録されたユーザ情報を取得する為に使用します
  # ==== _Args_
  # [login_id]
  #   ログインID
  # ==== _Return_
  # 該当レコード(存在しない場合、nil)
  #
  def get_login(login_id)
    Login.find_by_login_id(login_id, ProviderType::FACEBOOK)
  end
  
  #
  # 詳細情報取得
  # idに紐付くユーザ情報を取得します。
  # idが未設定の場合、newしただけのインスタンスを返します。
  # idが設定されていても該当データが存在しない場合、例外をthrowします
  # ==== _Args_
  # [resource_id]
  #   取得対象のリソースID
  # ==== _Return_
  # 該当レコード(see. <i>UserInfoLogic::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_detail(resource_id)

    result = UserInfoLogic::Detail.new
    
    if resource_id.to_s == ''
        result.resource = Resource.new
        result.user_info = UserInfo.new
        result.login = Login.new      
        return result
    end
    
    logic = ResourceLogic.new
    result.resource = logic.get_resource(resource_id, ResourceType::USER)
    result.user_info = UserInfo.find_by_resource_id(resource_id)
    result.login = Login.find_by_resource_id(resource_id)
    return result
  end
  
  #
  # 削除
  # ユーザ情報を削除します
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
    logic = ResourceLogic.new
    resource_id = params[:resource][:id]
    resource_version = params[:resource][:lock_version]
    logic.delete(resource_id, ResourceType::USER, resource_version)
    
    user_info_version = params[:user_info][:lock_version]
    user_info = UserInfo.find_by_resource_id(resource_id)
    user_info[:lock_version] = user_info_version
    
    login_version = params[:login][:lock_version]
    login = Login.find_by_resource_id(resource_id)
    login[:lock_version] = login_version
    
    begin
      user_info.destroy
      login.destroy
    rescue ActiveRecord::StaleObjectError
      # lock_versionが不正の場合、該当レコード無しのExceptionをthrow
      raise CustomException::InvalidVersionException.new
    end

  end
  
  #
  # ユーザ詳細戻り値.
  #
  class Detail
    # 該当リソース
    attr_accessor :resource
    # 該当user_info
    attr_accessor :user_info
    # 該当login
    attr_accessor :login
  end
  
  private
    #
    # user_info更新
    # ==== _Args_
    # [id]
    #   リソースID
    # [params]
    #   ユーザ登録・更新情報
    # [action_resource_id]
    #   登録・更新処理実行ユーザリソースID
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    # [CustomException::InvalidVersionException]
    #   バージョンが合わない場合
    #
    def update_user_info(id, params, action_resource_id)
      user_info = UserInfo.find_by_resource_id(id)
      # 取得データの強制変更
      user_info[:validity_start_date] = nil
      
      # 更新するカラムを指定して、更新を行う
      clone_pamam = params[:user_info].clone
      clone_pamam[:update_resource_id] = action_resource_id
      
      begin
        
        begin
          user_info.update_attributes!(
                clone_pamam.slice(:admin_flg, :default_user_group, 
                  :lock_version, :mail, :per_page, :reading_character, 
                  :tel, :update_resource_id, 
                  :validity_end_date, :validity_start_date))
        rescue ActiveRecord::RecordInvalid => e
          raise CustomException::ValidationException.new(e.record.errors.full_messages)
        end
      
      rescue ActiveRecord::StaleObjectError
        # lock_versionが不正の場合、バージョンエラーのExceptionをthrow
        raise CustomException::InvalidVersionException.new
      end
    end
    
    #
    # login更新
    # パスワード情報が空の場合、更新しません
    # ==== _Args_
    # [id]
    #   リソースID
    # [params]
    #   ユーザ登録・更新情報
    # [action_resource_id]
    #   登録・更新処理実行ユーザリソースID
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    # [CustomException::InvalidVersionException]
    #   バージョンが合わない場合
    #
    def update_login(id, params, action_resource_id)
      
      password = params[:login][:password]
      if password.to_s == ''
        # パスワードが未設定の場合、更新しない
        return
      end
      
      login = Login.find_by_resource_id(id)
      # 取得データの強制変更
      login[:password] = nil

      # 更新するカラムを指定して、更新を行う
      clone_pamam = {}
      clone_pamam[:update_resource_id] = action_resource_id
      clone_pamam[:password] = Digest::SHA512.hexdigest(params[:login][:password])
      clone_pamam[:lock_version] = params[:login][:lock_version]

      begin
        
        begin
          login.update_attributes!(clone_pamam)
        rescue ActiveRecord::RecordInvalid => e
          raise CustomException::ValidationException.new(e.record.errors.full_messages)
        end
      
      rescue ActiveRecord::StaleObjectError
        # lock_versionが不正の場合、バージョンエラーのExceptionをthrow
        raise CustomException::InvalidVersionException.new
      end
    end

    
    #
    # 登録・更新validate
    # 有効開始日の必須チェック
    # 有効終了日が空文字の場合、最大日付を設定する
    # 有効開始日 > 有効終了日の関係の場合、validateエラー
    # ==== _Args_
    # [params]
    #   ユーザ登録・更新情報
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
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
    # ==== _Args_
    # [params]
    #   ユーザ登録・更新情報
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
    def validate_insert(params)
      password = params[:login][:password]
      confirm_password = params[:login][:confirm_password]
      if password.to_s == ''
        raise CustomException::ValidationException.new(["パスワードは必須です。"])
      end
      
      check_password_length(password)
      check_password_confirm(password, confirm_password)
    end

    #
    # 更新validate
    # パスワードが6文字より少ない場合、エラー
    # ==== _Args_
    # [params]
    #   ユーザ登録・更新情報
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
    def validate_update(params)
      password = params[:login][:password]
      confirm_password = params[:login][:confirm_password]
      check_password_length(password)
      check_password_confirm(password, confirm_password)
    end
    
    #
    # パスワード長チェック
    # 6文字より少ない場合、例外をthrowします
    # ==== _Args_
    # [password]
    #   パスワード文字列
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
    def check_password_length(password)
      if password.to_s != "" && password.length < 6
        raise CustomException::ValidationException.new(["パスワードは6文字以上設定して下さい。"])
      end
    end

    #
    # パスワード確認チェック
    # パスワードと確認用パスワードが合致しない場合、例外をthrowします
    # ==== _Args_
    # [password]
    #   パスワード文字列
    # [confirm_password]
    #   確認用パスワード文字列
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    #
    def check_password_confirm(password, confirm_password)
      if password.to_s != ""
        if password != confirm_password
          raise CustomException::ValidationException.new(["パスワードとパスワード(確認用)の値が違います"])
        end
      end
    end

end
