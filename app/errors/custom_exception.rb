#
# カスタムExceptionのmodule
# 
module CustomException
  
  #
  # 不正入力値が渡された時の例外
  #
  class IllegalParameterException < StandardError
  end

  #
  # 該当レコード無し時の例外
  #
  class NotFoundException < StandardError
  end

  #
  # バージョンエラーの時の例外
  #
  class InvalidVersionException < StandardError
  end

  #
  # validation時の例外
  #
  class ValidationException < StandardError
    # エラーメッセージList
    attr_accessor :msgs
    
    #
    # コンストラクタ
    # ==== _Args_
    # [msgs]
    #   エラーメッセージList
    #
    def initialize msgs
      @msgs = msgs
    end
  end

end