#
# データを保持するEntity
#
module Entity
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
  end
end