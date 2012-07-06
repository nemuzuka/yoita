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
    # rollbackする為にはブロック内で例外を投げる必要があります。
    # Service側の呼び出しイメージは以下の通りです
    #   def something_method(...)
    #     transaction_handler do
    #       ...Service本体の処理...
    #     end
    #   end
    #
    def transaction_handler
      ActiveRecord::Base.transaction do
        
        if block_given?
          yield
        end
        
      end
    end
    
  end
end