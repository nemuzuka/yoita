# encoding: utf-8

module Ajax #:nodoc:
  
  #
  # 管理者機能の共通Contoroller.
  # 設備
  # ユーザグループ
  # 設備グループ
  # の管理機能はこれでカバーできます
  #
  class AdminAjaxCommonController < BaseController::JsonController

    #
    # 検索条件取得
    # Session上に格納されている検索条件を取得します
    #
    def get_serch_info
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        search_param = session[get_search_param_symble]
        search_param = create_search_param if search_param == nil
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
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        search_param = session[get_search_param_symble]
        search_param = create_search_param if search_param == nil
        
        # リクエストパラメータの情報を検索条件に設定する
        set_search_param(search_param)

        # 1ページ目から検索
        search_param.page = 1
        # 検索ボタンを押下した状態
        search_param.click_search = true
        
        # 検索して、結果を戻す
        render json: create_json_result(search_param)
      end
    end

    #
    # 一覧リフレッシュ処理
    # Sessionに格納されている検索条件を元に、再検索を行い、一覧を取得します
    #
    def refresh
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        search_param = session[get_search_param_symble]
        search_param = create_search_param if search_param == nil
        
        json_result = nil
        if search_param.click_search != nil && search_param.click_search == true
          # 検索ボタンを押下されている場合のみ、検索を行う
          json_result = create_json_result(search_param)
        else
          # 検索ボタンを押下されていない場合は、空の結果を返す
          list_result = Entity::ListResult.new
          list_result.list = []
          list_result.link = ""
          list_result.total_count = 0
          json_result = Entity::JsonResult.new
          json_result.result = list_result
        end
        render json: json_result
      end
    end

    #
    # ページング処理.
    # 入力されたページ番号に対して、
    # Sessionに格納された検索条件を元に、検索し、検索条件に合致するデータを取得します。
    #
    def turn
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        search_param = session[get_search_param_symble]
        search_param = create_search_param.new if search_param == nil
        
        # ページ番号を変更
        page_no = params[:page_no].to_i
        page_no = 1 if page_no == 0
        search_param.page = page_no
        
        render json: create_json_result(search_param)
      end
      
    end

    #
    # 登録・更新情報取得
    # リクエストパラメータにリソースIDが設定されていればその情報、
    # そうでなければ新規データとしてレスポンスを返却します
    #
    def show
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        resource_id = params[:resource_id]
        service = get_service
          
        result = Entity::JsonResult.new
        result.result = service.get_resource(resource_id)
        render json: result
      end
    end
    
    #
    # 登録・更新
    # リクエストパラメータを元に登録/更新を行います。
    #
    def save
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        
        # リクエストパラメータを元に登録・更新
        service = get_service
        service.save(params, get_user_info.resource_id)
        
        result = Entity::JsonResult.new
        result.info_msgs.push("正常に終了しました");
        render json: result
      end
    end
    
    #
    # 削除
    # リクエストパラメータを元に削除を行います
    #
    def destroy
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        service = get_service
        resource_id = params[:resource_id]
        lock_version = params[:lock_version]
        service.delete(resource_id, lock_version)
        
        result = Entity::JsonResult.new
        result.info_msgs.push("正常に終了しました");
        render json: result
      end
    end
    
    #
    # ソート情報取得
    # 登録されている全ての情報を取得します
    #
    def get_sort_info
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        # ページング無しで全件取得
        search_param = Resource::SearchParam.new
        service = get_service
        list = service.find_by_conditions(search_param)
        
        result = Entity::JsonResult.new
        result.result = list
        if list.length == 0
          result.info_msgs.push("一覧に表示するレコードが存在しません")
        end
        render json: result
      end
    end
    
    #
    # ソート順更新
    # 指定されているリソースIDの順番でソート順を更新します
    #
    def update_sort_order
      exeption_handler([Authentication::SCHEDULER_ADMIN]) do
        ids = params[:ids]
        service = get_service
        service.update_sort_num(ids)
        
        result = Entity::JsonResult.new
        result.info_msgs.push("正常に終了しました");
        render json: result
      end
    end

    protected
      #
      # 検索条件格納インスタンスSession格納シンボル取得
      # ==== _Return_
      # 検索条件格納インスタンスSession格納シンボル
      #
      def get_search_param_symble
        return :resource_search_param
      end

      #
      # 検索条件格納インスタンス生成
      # ==== _Return_
      # 検索条件格納インスタンス
      #
      def create_search_param
        Resource::SearchParam.new
      end

      #
      # 検索条件設定
      # リクエストパラメータを元に、検索条件を設定します
      # [search_param]
      #   検索条件パラメータ
      #
      def set_search_param(search_param)
        # リクエストパラメータの情報を設定
        search_param.name = params[:name]
      end

      #
      # 一覧戻り値作成
      # 検索条件に紐付くデータを取得し、Json戻り値を作成します。
      # [search_param]
      #   検索条件パラメータ
      #
      def create_json_result(search_param)
        # 1ページ辺りの表示件数が未設定の場合
        user_info = get_user_info()
        search_param.per = user_info.per_page if search_param.per == nil

        # 検索処理呼び出し
        service = get_service
        list = service.find_by_conditions(search_param)

        json_result = Entity::JsonResult.new        
        # トータル件数が0件の場合、メッセージを設定
        if search_param.total_count.to_i == 0
          json_result.info_msgs.push("一覧に表示するレコードが存在しません")
          search_param.click_search = false
        end
        list_result = Entity::ListResult.new
        list_result.list = list
        list_result.link = PagerHelper.crate_page_link(
          search_param, get_function_name, get_app_path)
        list_result.total_count = search_param.total_count

        json_result.result = list_result
        return json_result
      end
    
  end
end
