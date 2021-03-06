# encoding: utf-8

#
# データを保持するEntity
#
module Entity
  #
  # JSON形式の共通戻り値
  #
  class JsonResult
    # 正常終了
    STATUS_OK = 0

    # 異常終了(validateエラー)
    STATUS_NG = -1
    # Tokenエラー
    TOKEN_ERROR = -2
    # サーバーエラー(validateをすり抜けたDB整合性エラー)
    SERVER_ERROR = -3
    # 更新時バージョンエラー
    VERSION_ERR = -4
    # 一意制約エラー(入力値による一意制約発生時)
    DUPLICATE_ERR = -5
    # 該当データ無し
    NO_DATA = -6
    # 権限無し
    AUTHENTICATION_ERR = -7
    # Sessionタイムアウト
    SESSION_TIMEOUT = -99;

    # メッセージ
    attr_accessor :info_msgs
    # エラーメッセージ
    attr_accessor :error_msgs

    # ステータスコード
    attr_accessor :status_code

    # 結果
    attr_accessor :result

    # token文字列
    attr_accessor :token
    
    #
    # コンストラクタ
    #
    def initialize
      @info_msgs = []
      @error_msgs = []
      @status_code = STATUS_OK
      @result = nil
      @token = ""
    end
    
  end

  #
  # ログインユーザ情報を保持するclass
  #
  class UserInfo
    # ログインID
    attr_accessor :login_id
    # 名称
    attr_accessor :name
    # リソースID
    attr_accessor :resource_id
    # 管理者フラグ
    attr_accessor :admin_flg
    # デフォルト表示ユーザグループ
    attr_accessor :default_user_group

    # 保有権限
    attr_accessor :authentications

    # 1ページあたりの表示件数
    attr_accessor :per_page
    
    #
    # 管理者ユーザか
    # ==== _Return_
    # 管理者ユーザの場合、true
    #
    def admin?
      if @admin_flg != nil && @admin_flg == true
        return true
      end

      return false
    end
    
  end

  #
  # 一覧を返すJsonオブジェクト
  #
  class ListResult
    # 一覧
    attr_accessor :list
    
    # リンク文字列(Htmlタグ)
    attr_accessor :link
    
    # トータル件数
    attr_accessor :total_count
    
  end

  #
  # Key - Valueを保持するオブジェクト
  # 主にselectタグの構成情報として使用します
  #
  class LabelValueBean
    # キー
    attr_accessor :key
    # 値
    attr_accessor :value
    
    #
    # コンストラクタ
    # ==== _Args_
    # [key]
    #   Key値
    # [value]
    #   value値
    #
    def initialize(key, value)
      @key = key
      @value = value
    end
  end

end