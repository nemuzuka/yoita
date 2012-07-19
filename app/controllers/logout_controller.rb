#
# ログアウトに関するController
#
class LogoutController < BaseController::HtmlNoLoginController
  
  #
  # ログアウトします
  #
  def index
    reset_session
    redirect_to "/"
  end

end