#
# ログインに関するController
#
class LoginController < BaseController::HtmlNoLoginController
  
  #
  # index
  # ログイン画面を表示します
  #
  def index
  end
  
  #
  # 認証処理.
  # 認証成功時、Sessionを破棄して再作成します。
  #
  def execute
    exeption_handler do
      # TODO 認証に失敗した場合、エラーを表示して再度ログイン画面を表示
      
      # 認証成功時
      user_info = Entity::UserInfo.new
      user_info.login_id = "hogehogehoge"
      user_info.name = "ababababa"
      user_info.resource_id = 1234567
      user_info.admin_flg = true
      
      super.re_create_session(user_info)
      render :controller => "schedule"
    end
  end
  
end