class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      t.integer :resource_id, :limit=>8
      t.string :reading_character, :limit=>128
      t.string :tel, :limit=>48
      t.string :mail, :limit=>256
      t.string :admin_flg, :limit=>1
      t.integer :per_page, :limit=>3
      t.integer :default_user_group, :limit=>8
      t.date :validity_start_date
      t.date :validity_end_date
      t.integer :entry_resource_id, :limit=>8
      t.integer :update_resource_id, :limit=>8
      t.integer :lock_version, :limit=>8, :default => 0

      t.timestamps
    end
    
    # user_infosテーブルのindex付与
    add_index :user_infos, [:resource_id], :unique=>false, :name => 'user_info_idx_01'
    add_index :user_infos, [:validity_start_date, :validity_end_date], :unique=>false, :name => 'user_info_idx_02'
    add_index :user_infos, [:reading_character], :unique=>false, :name => 'user_info_idx_03'
  end
end
