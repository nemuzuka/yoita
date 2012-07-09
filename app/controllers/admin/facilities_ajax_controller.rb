#
# 管理者用機能のModule
#
module Admin #:nodoc:

  #
  # 設備管理のAjaxに関するController
  #
  class FacilitiesAjaxController < BaseController::JsonController
    #
    # 検索条件取得
    # Session上に格納されている検索条件を取得します
    #
    def get_serch_info
      
    end
  
    #
    # 検索結果取得
    # リクエストパラメータに該当する検索結果の一覧を取得します
    #
    def list
      
    end
  
    #
    # ページング処理.
    # 入力されたページ番号に対して、
    # Sessionに格納された検索条件を元に、検索し、検索条件に合致するデータを取得します。
    #
    def turn
      
    end
    
    #
    # 登録・更新情報取得
    # リクエストパラメータにリソースIDが設定されていればその情報、
    # そうでなければ新規データとしてレスポンスを返却します
    #
    def get_edit_info
      
    end
    
    #
    # 登録・更新
    # リクエストパラメータを元に登録/更新を行います。
    #
    def save
      
    end
    
    #
    # 削除
    # リクエストパラメータを元に削除を行います
    #
    def delete
      
    end
    
    #
    # ソート情報取得
    # 登録されている全ての情報を取得します
    #
    def get_sort_info
      
    end
    
    #
    # ソート順更新
    # 指定されているリソースIDの順番でソート順を更新します
    #
    def update_sort_order
      
    end
  end
end
