# encoding: utf-8

#
# Controllerの基底クラス.
#
class ApplicationController < ActionController::Base
#  protect_from_forgery #=>コメントアウトしてToken処理を自前で賄う

  # 優先的な前処理
  prepend_before_filter :prepare_session

  # sessionタイムアウト時間(秒単位)
  MAX_SESSION_TIME = 60 * 60

  # 以降、protectedメソッド  
  protected
  
    #
    # ログインチェック.
    # Session上にユーザ情報が存在する場合、ログイン済みであると判断します。
    # ==== _Return_
    # ログイン済みの場合:true/未ログインの場合:false
    #
    def logined?
      user_info = session[:user_info]
      if user_info == nil || user_info.login_id = nil
        return false
      end
      return true
    end

    #
    # Token値取得.
    # Session上にToken値を設定します。
    # ==== _Return_
    # 設定Token値
    #
    def get_authenticity_token
      super.form_authenticity_token
      return session[:_csrf_token]
    end


    #
    # Sessionタイムアウトチェック
    # Sessionが有効期間を超えている場合、Sessionを削除します
    # 有効期間を超えてない場合、Sessionの有効期限を再作成します。
    #
    def prepare_session
      if !session[:expiry_time].nil? and session[:expiry_time] < Time.now
        # Sessionが存在して、有効期間を超えている場合、Sessionを削除
        reset_session
      end

      # Sessionの有効期限を現在時刻 + タイムアウト時間に設定する.
      session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now
    end

    #
    # 現在存在するSessionを破棄して、新しくSessionを作成し、ユーザ情報を設定します。
    # 認証成功時または、画面切り替え時のSession情報を削除する際に使用することを想定しています。
    # ==== _Args_
    # [user_info]
    #   認証済みユーザ情報(see. <i>Entity::UserInfo</i>)
    #
    def re_create_session(user_info)
      # Session破棄
      reset_session
      
      # Sessionの有効期限を現在時刻 + タイムアウト時間に設定する.
      session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now
      session[:user_info] = user_info
    end

    #
    # ユーザ情報取得.
    # Session上に設定されている、ユーザ情報を取得します。
    # ==== _Return_
    # ユーザ情報(存在しない場合、nil see. <i>Entity::UserInfo</i>)
    #
    def get_user_info
      return session[:user_info]
    end

end
