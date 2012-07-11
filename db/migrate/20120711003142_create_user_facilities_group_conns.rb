class CreateUserFacilitiesGroupConns < ActiveRecord::Migration
  def change
    create_table :user_facilities_group_conns do |t|
      t.integer :parent_resource_id, :limit=>8
      t.integer :child_resource_id, :limit=>8
    end
    # resourcesテーブルのindex付与
    add_index :resources, [:name], :unique=>false, :name => 'resource_idx_01'
    add_index :resources, [:resource_type], :unique=>false, :name => 'resource_idx_02'
    add_index :resources, [:sort_num], :unique=>false, :name => 'resource_idx_03'

    # user_facilities_group_connsテーブルのindex付与
    add_index :user_facilities_group_conns, [:parent_resource_id], :unique=>false, :name => 'user_facilities_group_conn_idx_01'
  end
end
