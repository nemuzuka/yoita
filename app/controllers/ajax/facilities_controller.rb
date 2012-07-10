# encoding: utf-8
require "resource_search_param"

module Ajax #:nodoc:
  #
  # 設備管理のAjaxに関するController
  #
  class FacilitiesController < BaseController::JsonController

    #
    # 検索条件取得
    # Session上に格納されている検索条件を取得します
    #
    def get_serch_info
      exeption_handler do
        search_param = session[:resource_search_param]
        result = Entity::JsonResult.new
        result.result = search_param
        render json: result
      end
    end
  
    #
    # 検索結果取得
    # リクエストパラメータに該当する検索結果の一覧を取得します
    #
    def list
      
    end
  
    #
    # ページング処理.
    # 入力されたページ番号に対して、
    # Sessionに格納された検索条件を元に、検索し、検索条件に合致するデータを取得します。
    #
    def turn
      
    end
    
    #
    # 登録・更新情報取得
    # リクエストパラメータにリソースIDが設定されていればその情報、
    # そうでなければ新規データとしてレスポンスを返却します
    #
    def show
      exeption_handler do
        resource_id = params[:resource_id]
        resource = nil
        if(resource_id != nil && resource_id != "")
          # 詳細データを取得
          service = FacilitiesService.new
          resource = service.get_resource(resource_id)
        else
          resource = Resource.new
        end
        result = Entity::JsonResult.new
        result.result = resource
        render json: result
      end
    end
    
    #
    # 登録・更新
    # リクエストパラメータを元に登録/更新を行います。
    #
    def update
      
    end
    
    #
    # 削除
    # リクエストパラメータを元に削除を行います
    #
    def destroy
      
    end
    
    #
    # ソート情報取得
    # 登録されている全ての情報を取得します
    #
    def get_sort_info
      
    end
    
    #
    # ソート順更新
    # 指定されているリソースIDの順番でソート順を更新します
    #
    def update_sort_order
      
    end
  end
end
