# encoding: utf-8

#
# 初期構築時にユーザを登録する為のController
# メインで使用される機能ではありません
#
class UserCreateController < ApplicationController
  
  def index
    login_id = params[:login_id]
    password = params[:password]
    
    params[:resource] = {}
    params[:resource][:name] = login_id
    params[:resource][:memo] = "auto added."
    
    params[:user_info] = {}
    params[:user_info][:reading_character] = ""
    params[:user_info][:tel] = ""
    params[:user_info][:mail] = ""
    params[:user_info][:admin_flg] = "1"
    params[:user_info][:per_page] = "10"
    params[:user_info][:validity_start_date] = ApplicationHelper::get_current_date.strftime("%Y/%m/%d")

    params[:login] = {}
    params[:login][:login_id] = login_id
    params[:login][:password] = password
    params[:login][:confirm_password] = password
    
    service = UserInfosService.new
    service.save(params, -1)
    
    result = Entity::JsonResult.new
    result.info_msgs.push("正常に終了しました");
    render json: result
  end
  
end