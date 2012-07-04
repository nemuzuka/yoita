# カスタムException
module CustomException
  
  # 不正入力値が渡された時の例外
  class IllegalParameterException < StandardError
  end

  # 該当レコード無し時の例外
  class NotFoundException < StandardError
  end

  # validation時の例外
  class ValidationException < StandardError
    def initialize msgs
      @msgs = msgs
    end
    attr_accessor :msgs
  end

end