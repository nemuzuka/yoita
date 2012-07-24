class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :title,:limit=>64
      t.string :memo,:limit=>1024
      t.string :closed_flg,:limit=>1
      t.date :start_date
      t.string :start_time,:limit=>4
      t.date :end_date
      t.string :end_time,:limit=>4
      t.string :repeat_conditions,:limit=>1
      t.string :repeat_week,:limit=>1
      t.string :repeat_day,:limit=>2
      t.string :repeat_endless,:limit=>1
      t.integer :entry_resource_id,:limit=>8
      t.integer :update_resource_id,:limit=>8
      t.integer :lock_version, :limit=>8, :default => 0

      t.timestamps
    end
    # schedulesテーブルのindex付与
    add_index :schedules, [:start_date, :end_date], :unique=>false, :name => 'schedules_idx_01'
    
  end
end
