# encoding: utf-8

#
# Html/Jsonを返す際の規定Controller
#
module BaseController

  #
  # Htmlを返すControllerの基底クラス
  # 主に、ログイン処理にて使用
  #
  class HtmlNoLoginController < ApplicationController

    protected
      #
      # 例外に関するHandler
      # Controller側の呼び出しイメージは以下の通りです
      #   def something_method
      #     exeption_handler do
      #       ...Controller本体の処理...
      #     end
      #   end
      # 権限チェックを行う場合、引数に設定します。
      # チェック対象権限と比較方法を元に、呼び出し許可を有するかチェックします。
      #
      #   def something_method
      #     exeption_handler([Authentication::SCHEDULER_ADMIN], AuthenticationCheckType::AND) do
      #       ...Controller本体の処理...
      #     end
      #   end
      #
      # ==== _Args_
      # [authentications]
      #   チェック対象権限List(see. <i>Authentication</i>)
      # [authentication_check_type]
      #   比較方法(<i>AuthenticationCheckType::AND</i>:全て有さなければエラー、<i>AuthenticationCheckType::OR</i>:1つ以上有さなければエラー)
      #
      def exeption_handler(authentications = [], authentication_check_type = AuthenticationCheckType::AND)
        
        begin
          check_authentication(authentications, authentication_check_type)
        rescue CustomException::IllegalAuthenticationException => e
          # 使用権限無し
          reset_session
          flash[:notice] = "この機能は利用不可能です。"
          redirect_to :controller => "/login", :action => "index"
          return
        end

        if block_given?
          begin
            expires_now
            yield
          rescue => e
            logger.error e.message if logger
            redirect_to :controller => "/login", :action => "index"
          end
          
        end
      end
    
  end
  
  #
  # Htmlを返すControllerの基底クラス
  # ログイン済みの処理に対して実施
  #
  class HtmlController < HtmlNoLoginController

    before_filter :token_check
    before_filter :login_check
    
    private
      #
      # Tokenチェック.
      # Tokenチェックを行い、エラーが発生した際、ログイン画面へ遷移します。
      #
      def token_check
        if verified_request? == false
          # →今回の使い方では発生しないはず
          redirect_to :controller => "/login", :action => "index"
          return false
        end
      end

      #
      # loginチェック.
      # SessionにUserInfoが存在するか判断し、
      # 存在しない場合、リクエストのパスをflashに格納し、ログイン画面へ遷移します。
      #
      def login_check
        if logined? == false
          reset_session
          flash[:referer] = request.fullpath
          flash[:notice] = "一定時間操作されなかったのでタイムアウトしました。"
          redirect_to :controller => "/login", :action => 'index'
          return false
        end
      end
  end
  
  #
  # Jsonを返すControllerの基底クラス
  #
  class JsonController < ApplicationController
    before_filter :login_check
    before_filter :token_check
    
    protected
      #
      # 例外に関するHandler
      # Controller側の呼び出しイメージは以下の通りです
      #   def something_method
      #     exeption_handler do
      #       ...Controller本体の処理...
      #     end
      #   end
      # 権限チェックを行う場合、引数に設定します。
      # チェック対象権限と比較方法を元に、呼び出し許可を有するかチェックします。
      #
      #   def something_method
      #     exeption_handler([Authentication::SCHEDULER_ADMIN], AuthenticationCheckType::AND) do
      #       ...Controller本体の処理...
      #     end
      #   end
      #
      # ==== _Args_
      # [authentications]
      #   チェック対象権限List(see. <i>Authentication</i>)
      # [authentication_check_type]
      #   比較方法(<i>AuthenticationCheckType::AND</i>:全て有さなければエラー、<i>AuthenticationCheckType::OR</i>:1つ以上有さなければエラー)
      #
      def exeption_handler(authentications = [], authentication_check_type = AuthenticationCheckType::AND)

        begin
          check_authentication(authentications, authentication_check_type)
        rescue CustomException::IllegalAuthenticationException => e
          # 使用権限無し
          render json: createJsonResult(Entity::JsonResult::AUTHENTICATION_ERR, 
            ["この機能は利用不可能です"])
          return
        end

        if block_given?

          begin
            expires_now
            yield
          rescue CustomException::NotFoundException
            # 該当レコード無し
            render json: createJsonResult(Entity::JsonResult::NO_DATA, 
              ["該当レコードが存在しません"])
          rescue CustomException::InvalidVersionException
            # バージョン不正
            render json: createJsonResult(Entity::JsonResult::VERSION_ERR, 
              ["他のユーザに更新された可能性があります"])
          rescue CustomException::ValidationException => e
            # validateエラー
            render json: createJsonResult(Entity::JsonResult::STATUS_NG, 
              e.msgs)
          rescue CustomException::UniqueConstraintException => e
            # 一意制約エラー
            target = get_unique_data_name
            render json: createJsonResult(Entity::JsonResult::DUPLICATE_ERR, 
              ["入力された" + target + "は既に登録されています"])
          rescue => e
            logger.error e.message if logger
            render json: createJsonResult(Entity::JsonResult::SERVER_ERROR, 
              ["システムエラーが発生しました"])
          end
          
        end
      end
      
      #
      # 一意制約違反時のメッセージ取得
      # ==== _Return_
      # 一意制約違反時のメッセージ
      #
      def get_unique_data_name
        return "データ"
      end

    private
      #
      # Tokenチェック.
      # Tokenチェックを行い、エラーが発生した際、Tokenエラーを意味するJsonレスポンスを返します。
      #
      def token_check
        if verified_request? == false
          render json: createJsonResult(Entity::JsonResult::TOKEN_ERROR, 
            ["「戻る」ボタンを押されたか、他のブラウザによって変更されている可能性があります。もう一度読み込みなおしてから処理を行ってください。"])
          return false
        end
      end
      
      #
      # loginチェック.
      # SessionにUserInfoが存在するか判断し、
      # 存在しない場合、Sessionタイムアウトを意味するJsonレスポンスを返します。
      #
      def login_check
        if logined? == false
          render json: createJsonResult(Entity::JsonResult::SESSION_TIMEOUT, 
            ["一定時間操作されなかったのでタイムアウトしました。"])
          return false
        end
      end
    
      #
      # エラーJsonResultインスタンス生成
      # ==== _Args_
      # [status_code]
      #   ステータスコード
      # [error_msgs]
      #   エラーメッセージ配列
      # ==== _Return_
      # 生成JsonResultインスタンス
      #
      def createJsonResult(status_code, error_msgs)
        json_result = Entity::JsonResult.new
        json_result.status_code = status_code
        json_result.error_msgs = error_msgs
        return json_result
      end
    
  end
  
end