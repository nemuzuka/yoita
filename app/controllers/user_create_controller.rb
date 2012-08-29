# encoding: utf-8

#
# 初期構築時にユーザを登録する為のController
# メインで使用される機能ではありません
#
class UserCreateController < ApplicationController
  
  def index
    login_id = params[:login_id]
    password = params[:password]
    
    service = UserInfosService.new
    # 管理者権限でユーザを新規登録
    service.force_save(login_id, password, ProviderType::YOITA, "1")
    
    result = Entity::JsonResult.new
    result.info_msgs.push("正常に終了しました");
    render json: result
  end
  
end