class AddIndex < ActiveRecord::Migration
  def up
    # national_holidaysテーブルのindex付与
    remove_index :national_holidays, :name => 'national_holidays_idx_01'
    remove_index :national_holidays, :name => 'national_holidays_idx_02'
    
    add_index :national_holidays, [:target_year], :unique=>false, :name => 'national_holidays_idx_01'
    add_index :national_holidays, [:target_date], :unique=>true, :name => 'national_holidays_unique_idx_01'
  end

  def down
  end
end
