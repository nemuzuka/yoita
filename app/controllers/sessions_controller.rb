# encoding: utf-8

#
# FBと連携するController
#
class SessionsController < ApplicationController
  
  # 認証成功時のコールバック
  def callback
    # omniauth.auth環境変数を取得
    auth = request.env["omniauth.auth"]
    # Userとして登録されているかチェック、登録されていなければユーザ情報として登録
    resource_id = nil
    user_infos_service = UserInfosService.new
    login = user_infos_service.get_login(auth["uid"])
    if login == nil
      # 存在しないので、DBに登録する
      resource = user_infos_service.force_save(auth["uid"], "4Facebook", ProviderType::FACEBOOK, "0")
      resource_id = resource[:id]
    else
      resource_id = login[:resource_id]
    end
    
    service_detail = user_infos_service.get_resource(resource_id)
    resource = service_detail.detail.resource
    user_info_model = service_detail.detail.user_info
    # 有効期間終了日がnilの場合、最大値が設定されているとみなす
    user_info_model[:validity_end_date] = MAX_DATE if user_info_model[:validity_end_date] == nil

    now_date = ApplicationHelper::get_current_date
    if user_info_model[:validity_start_date] > now_date || now_date > user_info_model[:validity_end_date]
      # システム日付において、有効なユーザでない場合、ログイン画面へ遷移
      flash[:notice] = "現在無効なユーザです。"
      redirect_to "/"
      return
    end
    
    # Session情報を作成し、TOP画面へ遷移
    user_info = create_user_info(service_detail)
    
    # Session再作成
    re_create_session(user_info)
    
    redirect_to "/schedule"
  end
  
  # 認証キャンセル時のコールバック
  def oauth_failure
    flash[:notice] = "Facebookによる認証をキャンセルしました。"
    redirect_to "/"
  end
    
end
