class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
      t.integer :resource_id, :limit=>8
      t.string :login_id, :limit=>256
      t.string :password, :limit=>256
      t.integer :entry_resource_id, :limit=>8
      t.integer :update_resource_id, :limit=>8
      t.integer :lock_version, :limit=>8, :default => 0

      t.timestamps
    end
    
    # loginsテーブルのindex付与
    add_index :logins, [:resource_id], :unique=>false, :name => 'login_idx_01'
    add_index :logins, [:login_id], :unique=>true, :name => 'login_unique_idx_01'
    
  end
end
