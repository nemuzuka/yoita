class CreateScheduleFollows < ActiveRecord::Migration
  def change
    create_table :schedule_follows do |t|
      t.integer :schedule_id,:limit=>8
      t.integer :parent_schedule_follow_id,:limit=>8
      t.string :memo,:limit=>1024
      t.integer :entry_resource_id,:limit=>8
      t.integer :update_resource_id,:limit=>8

      t.timestamps
    end
    
    # schedule_followsテーブルのindex付与
    add_index :schedule_follows, [:schedule_id], :unique=>false, :name => 'schedule_follows_idx_01'
    add_index :schedule_follows, [:parent_schedule_follow_id], :unique=>false, :name => 'schedule_follows_idx_02'
    
  end
end
