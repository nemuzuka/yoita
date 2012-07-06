#
# 各種サービスの基底Module.
#
module Service
  
  #
  #基底class
  #
  class Base
    protected
    
    #
    # トランザクションをかけるhandler.
    # rollbackする為にはブロック内で例外を投げる必要があります
    # ==== _Args_
    # [args]
    #   処理パラメータ
    #
    def transaction_handler(*args)
      ActiveRecord::Base.transaction do
        
        if block_given?
          yield
        end
        
      end
    end
    
  end
end