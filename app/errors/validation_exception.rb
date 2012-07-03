# validation時の例外
class ValidationException < StandardError
  def initialize msgs
    @msgs = msgs
  end
  attr_accessor :msgs
end
