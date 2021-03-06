# encoding: utf-8

module Ajax #:nodoc:
  #
  # ユーザ管理のAjaxに関するController
  #
  class UserInfosController < Ajax::AdminAjaxCommonController

    #
    # ログインユーザ情報取得
    #
    def show_self
      exeption_handler do
        resource_id = get_user_info.resource_id
          
        result = Entity::JsonResult.new
        result.result = get_service.get_resource(resource_id)
        render json: result
      end
    end

    #
    # 更新
    # リクエストパラメータを元にログインユーザの情報を更新します。
    #
    def save_self
      exeption_handler do
        
        # リクエストパラメータを元に登録・更新
        get_service.save_self(params, get_user_info.login_id, get_user_info.resource_id)
        
        # 更新後の情報でUserInfo更新
        service_detail = get_service.get_resource(get_user_info.resource_id)
        user_info = create_user_info(service_detail)
        session[:user_info] = user_info
        
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
        service.delete(params)
        
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
        service = get_service
        list = service.get_all_users
        
        result = Entity::JsonResult.new
        result.result = list
        if list.length == 0
          result.info_msgs.push("一覧に表示するレコードが存在しません")
        end
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
        return :user_info_search_param
      end

      #
      # 検索条件格納インスタンス生成
      # ==== _Return_
      # 検索条件格納インスタンス
      #
      def create_search_param
        UserInfo::SearchParam.new
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
        search_param.reading_character = params[:reading_character]
        admin_only = params[:admin_only]
        search_param.admin_only = false
        search_param.admin_only = true if admin_only.to_s == '1'

        search_param.resource_id = nil
        search_param.resource_id_list = nil
        
        search_type = params[:search_type]
        if search_type == SearchType::EXCLUDE_DISABLE_DATA || 
          search_type == SearchType::INCLUDE_DISABLE_DATA ||
          search_type == SearchType::ONLY_DISABLE_DATA

          search_param.search_type = search_type          
        else
          raise CustomException::IllegalParameterException.new
        end
        
        now = ApplicationHelper::get_current_date
        search_param.search_base_date = now if search_param.search_base_date != now
      end

      #
      # 使用Serviceインスタンス取得
      # ==== _Return_
      # 使用Serviceインスタンス
      #
      def get_service
        UserInfosService.new
      end
      
      #
      # ページングjs関数名取得
      # ==== _Return_
      # ページングjs関数名
      #
      def get_function_name
        return "turnUserInfos"
      end

      #
      # ページングpath取得
      # ==== _Return_
      # ページングpath
      #
      def get_app_path
        return "/ajax/userInfos/turn"
      end

      #
      # 一意制約違反時のメッセージ取得
      # ==== _Return_
      # 一意制約違反時のメッセージ
      #
      def get_unique_data_name
        return "ユーザ"
      end
  end
end
