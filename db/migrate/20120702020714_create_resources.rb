class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :resource_type,:limit=>3
      t.string :name,:limit=>128
      t.string :memo,:limit=>1024
      t.integer :sort_num, :limit=>8
      t.integer :entry_resource_id, :limit=>8
      t.integer :update_resource_id, :limit=>8
      t.integer :lock_version, :limit=>8, :default => 0

      t.timestamps
    end
  end
end
