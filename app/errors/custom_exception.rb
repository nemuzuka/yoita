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
  # validation時の例外
  #
  class ValidationException < StandardError
    # エラーメッセージList
    attr_accessor :msgs
    
    #
    # コンストラクタ
    # ==== Args
    # _msgs_ :: エラーメッセージList
    #
    def initialize msgs
      @msgs = msgs
    end
  end

end