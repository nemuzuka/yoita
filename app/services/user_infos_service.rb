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
  # 有効終了日がデフォルト値の場合、nil値に上書きします
  # デフォルトユーザグループの構成情報も返却します
  # ==== _Args_
  # [id]
  #   取得対象id(空文字 or nullの場合、新規とみなす)
  # ==== _Return_
  # 該当レコード(see. <i>UserInfosService::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_resource(id)
    transaction_handler do
      
      logic = UserInfoLogic.new
      detail = logic.get_detail(id)
      user_info = detail.user_info
      if user_info.validity_end_date != nil && user_info.validity_end_date == MAX_DATE
        user_info.validity_end_date = nil
      end
      
      ret_detail = UserInfosService::Detail.new
      ret_detail.detail = detail
      
      # 全てのユーザグループを取得する
      resource_logic = ResourceLogic.new
      ret_detail.user_group_list = resource_logic.get_all_resources(ResourceType::USER_GROUP, true)
      return ret_detail
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
      logic.save(params, action_resource_id)
    end
  end
  
  #
  # ユーザ更新
  # ログインユーザ情報を更新します。
  # DBの整合性に合致しない場合、不正な入力値の場合、例外をthrowします 
  # ==== _Args_
  # [params]
  #   ユーザ登録・更新情報
  # [login_id]
  #   更新処理実行ログインID
  # [action_resource_id]
  #   更新処理実行ユーザリソースID
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
  def save_self(params, login_id, action_resource_id)
    transaction_handler do
      logic = UserInfoLogic.new
      before_confirm_password = params[:login][:before_confirm_password]
      password = params[:login][:password]
      if before_confirm_password != '' || password.to_s != ''
        if before_confirm_password == '' || password.to_s == ''
          raise CustomException::ValidationException.new(["変更前・変更後パスワードを入力して下さい"])
        end
        
        # パスワードが入力されている場合、認証する
        login = logic.auth(login_id, before_confirm_password)
        if login == nil
          raise CustomException::ValidationException.new(["変更前パスワードが合致しません。"])
        end
      else
        params[:login][:password] = ""
      end
      
      # 更新しないデータを上書き
      user_info = logic.get_detail(action_resource_id).user_info
      params[:user_info][:validity_start_date] = user_info[:validity_start_date].strftime("%Y/%m/%d")
      params[:user_info][:validity_end_date] = user_info[:validity_end_date].strftime("%Y/%m/%d")
      params[:user_info][:admin_flg] = user_info[:admin_flg]
      params[:resource][:id] = action_resource_id

      logic.save(params, action_resource_id)
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
      logic.update_sort_num(ids, ResourceType::USER)
    end
  end
  
  #
  # ユーザ一覧取得
  # 登録されている全ユーザを取得します
  # ==== _Return_
  # 該当レコード
  #
  def get_all_users
    transaction_handler do
      search_param = Resource::SearchParam.new
      search_param.resource_type = ResourceType::USER
      logic = ResourceLogic.new
      logic.find_by_conditions(search_param)
    end
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
    transaction_handler do
      logic = UserInfoLogic.new
      logic.auth(login_id, password)
    end
  end

  #
  # Login情報取得.
  # Facebook経由で登録されたユーザ情報を取得します
  # ==== _Args_
  # [uid]
  #   UID
  # ==== _Return_
  # 該当レコード(存在しない場合、nil)
  #
  def get_login(uid)
    transaction_handler do
      logic = UserInfoLogic.new
      logic.get_login(uid)
    end
  end
  
  #
  # ユーザ強制作成
  # 引数の情報のみで、ユーザ情報を登録します
  # ==== _Args_
  # [login_id]
  #   ログインID
  # [password]
  #   パスワード
  # [provider]
  #   認証区分 see.<i>ProviderType</i>
  # [admin_flg]
  #   管理者権限を付与する場合、"1"/一般の場合、"0"
  #
  def force_save(login_id, password, provider, admin_flg)
    transaction_handler do
      params = {}
      params[:resource] = {}
      params[:resource][:name] = "自動生成"
      params[:resource][:memo] = "auto added."
      
      params[:user_info] = {}
      params[:user_info][:reading_character] = ""
      params[:user_info][:tel] = ""
      params[:user_info][:mail] = ""
      params[:user_info][:admin_flg] = admin_flg
      params[:user_info][:per_page] = "10"
      params[:user_info][:validity_start_date] = ApplicationHelper::get_current_date.strftime("%Y/%m/%d")
  
      params[:login] = {}
      params[:login][:login_id] = login_id
      params[:login][:provider] = provider
      params[:login][:password] = password
      params[:login][:confirm_password] = password
      self.save(params, -1)
    end
  end
  
  #
  # 詳細データ
  #
  class Detail
    # 該当詳細データ
    attr_accessor :detail
    # ユーザグループ構成情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :user_group_list
  end
  
end
