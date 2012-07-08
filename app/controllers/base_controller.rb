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
      #
      def exeption_handler
        if block_given?

          begin
            yield
          rescue => e
            logger.error e.message if logger
            #TODO ログイン画面へリダイレクト
            redirect_to :controller => "login", :action => "index"
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
        if super.verified_request? == false
          # →今回の使い方では発生しないはず
          #TODO ログイン画面へリダイレクト
          redirect_to :controller => "login", :action => "index"
          return false
        end
      end

      #
      # loginチェック.
      # SessionにUserInfoが存在するか判断し、
      # 存在しない場合、リクエストのパスをflashに格納し、ログイン画面へ遷移します。
      #
      def login_check
        if super.logined? == false
          super.reset_session
          flash[:referer] = request.fullpath
          # TODO ログイン画面へリダイレクト
          redirect_to :controller => "login", :action => 'index'
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
      #
      def exeption_handler
        if block_given?

          begin
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
          rescue => e
            logger.error e.message if logger
            render json: createJsonResult(Entity::JsonResult::SERVER_ERROR, 
              ["システムエラーが発生しました"])
          end
          
        end
      end

    private
      #
      # Tokenチェック.
      # Tokenチェックを行い、エラーが発生した際、Tokenエラーを意味するJsonレスポンスを返します。
      #
      def token_check
        if super.verified_request? == false
          # TODO エラーメッセージをプロパティ化したい
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
        if super.logined? == false
          # TODO エラーメッセージをプロパティ化したい
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