#
# ログインに関するController
#
class LoginController < BaseController::HtmlNoLoginController
  
  #
  # index
  # ログイン画面を表示します
  #
  def index
      user_info = Entity::UserInfo.new
      user_info.login_id = "hogehogehoge"
      user_info.name = "ababababa"
      user_info.resource_id = 1234567
      user_info.admin_flg = true
      user_info.per_page = 3
      
      p user_info

      re_create_session(user_info)

  end
  
  #
  # 認証処理.
  # 認証成功時、Sessionを破棄して再作成します。
  #
  def auth
    exeption_handler do
      # TODO 認証に失敗した場合、エラーを表示して再度ログイン画面を表示
      
      # 認証成功時
      user_info = Entity::UserInfo.new
      user_info.login_id = "hogehogehoge"
      user_info.name = "ababababa"
      user_info.resource_id = 1234567
      user_info.admin_flg = true
      
      super.re_create_session(user_info)
      
      # リクエストパラメータに遷移先が設定されている場合はそのURLへ
      # 設定されていない場合、スケジューラの先頭へ遷移する
      referer = params[:referer]
      if(referer != nil && referer != '')
        redirect_to referer
      else
        render :controller => "schedule", :action => "index"
      end
    end
  end
  
end