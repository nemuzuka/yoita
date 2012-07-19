# encoding: utf-8

# NationalHoliday用のデフォルト値
FactoryGirl.define do
  factory :national_holiday1, :class => NationalHoliday do
    id 100001
    target_year "2010"
    target_month_day "0101"
    target_date "2010-01-01"
    memo "2010年1月1日"
  end

  factory :national_holiday2, :class => NationalHoliday do
    id 100002
    target_year "2010"
    target_month_day "0102"
    target_date "2010-01-02"
    memo "2010年1月2日"
  end

  factory :national_holiday3, :class => NationalHoliday do
    id 100003
    target_year "2010"
    target_month_day "0103"
    target_date "2010-01-03"
    memo ""
  end

  factory :national_holiday4, :class => NationalHoliday do
    id 100004
    target_year "2010"
    target_month_day "0104"
    target_date "2010-01-04"
    memo "2010年1月4日"
  end

  factory :national_holiday5, :class => NationalHoliday do
    id 100005
    target_year "2011"
    target_month_day "0101"
    target_date "2011-01-01"
    memo "2011年1月1日"
  end

  factory :national_holiday6, :class => NationalHoliday do
    id 100006
    target_year "2011"
    target_month_day "0102"
    target_date "2011-01-02"
    memo "2011年1月2日"
  end

  factory :national_holiday7, :class => NationalHoliday do
    id 100007
    target_year "2011"
    target_month_day "0103"
    target_date "2011-01-03"
    memo ""
  end

  factory :national_holiday8, :class => NationalHoliday do
    id 100008
    target_year "2011"
    target_month_day "0104"
    target_date "2011-01-04"
    memo "2011年1月4日"
  end

end
