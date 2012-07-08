#
# ログアウトに関するController
#
class LoginController < BaseController::HtmlNoLoginController
  
  #
  # ログアウトします
  #
  def index
    reset_session
    redirect_to "/"
  end

end