class CreateNationalHolidays < ActiveRecord::Migration
  def change
    create_table :national_holidays do |t|
      t.string :target_year, :limit=>4
      t.string :target_month_day, :limit=>4
      t.date :target_date
      t.string :memo, :limit=>1024
    end

    # national_holidaysテーブルのindex付与
    add_index :national_holidays, [:target_date], :unique=>false, :name => 'national_holidays_idx_01'
    add_index :national_holidays, [:target_year], :unique=>false, :name => 'national_holidays_idx_02'

  end
end
