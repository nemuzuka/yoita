class ChangeLogin < ActiveRecord::Migration
  def up
    # カラム追加
    add_column(:logins, :provider, :string, :limit=>1)
    
    # unique indexの再作成
    remove_index :logins, :name => 'login_unique_idx_01'
    add_index :logins, [:provider, :login_id], :unique=>true, :name => 'login_unique_idx_01'
    
    # 既に登録されているデータを更新する
    execute "update logins set provider = 'Y'"
  end

  def down
    remove_column(:logins, :provider)

    # unique indexの再作成
    remove_index :logins, :name => 'login_unique_idx_01'
    add_index :logins, [:login_id], :unique=>true, :name => 'login_unique_idx_01'
  end
end
