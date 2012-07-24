class CreateScheduleConns < ActiveRecord::Migration
  def change
    create_table :schedule_conns do |t|
      t.integer :schedule_id,:limit=>8
      t.integer :resource_id,:limit=>8
    end
    # schedule_connsテーブルのindex付与
    add_index :schedule_conns, [:schedule_id], :unique=>false, :name => 'schedule_conns_idx_01'
    add_index :schedule_conns, [:resource_id], :unique=>false, :name => 'schedule_conns_idx_02'
    
  end
end
