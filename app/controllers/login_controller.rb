# encoding: utf-8
require "constants"

#
# ログインに関するController
#
class LoginController < BaseController::HtmlNoLoginController
  
  layout :except => :index
  
  #
  # index
  # ログイン画面を表示します
  #
  def index
  end
  
  #
  # 認証処理.
  # 認証成功時、Sessionを破棄して再作成します。
  # 戻り値はjson形式です
  #
  def auth
    exeption_handler do
      login_id = params[:login_id]
      password = params[:password]
      
      service = UserInfosService.new
      login = service.auth(login_id, password)
      
      if login == nil
        # 認証に失敗した場合、エラーを意味するJSONを返却
        render_error_json_result("入力されたユーザID、パスワードが一致しません。")
        return
      end
      
      service_detail = service.get_resource(login[:resource_id])
      resource = service_detail.detail.resource
      user_info_model = service_detail.detail.user_info
      # 有効期間終了日がnilの場合、最大値が設定されているとみなす
      user_info_model[:validity_end_date] = MAX_DATE if user_info_model[:validity_end_date] == nil

      now_date = ApplicationHelper::get_current_date
      if user_info_model[:validity_start_date] > now_date || now_date > user_info_model[:validity_end_date]
        # システム日付において、有効なユーザでない場合、エラーを意味するJSONを返却
        render_error_json_result("現在無効なユーザです。")
        return
      end
      
      # 認証成功時
      user_info = create_user_info(service_detail)
      
      # Session再作成
      re_create_session(user_info)
      
      # 正常終了のJSONレスポンスを返却
      json_result = Entity::JsonResult.new
      render json: json_result
    end
  end
  
  private 
    #
    # エラーJSON出力
    # ==== _Args_
    # [msg]
    #   エラーメッセージ
    #
    def render_error_json_result(msg)
      re_create_session(nil)
      
      json_result = Entity::JsonResult.new
      json_result.status_code = Entity::JsonResult::STATUS_NG
      json_result.error_msgs.push(msg)
      render json: json_result
    end
end