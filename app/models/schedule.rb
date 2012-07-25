# encoding: utf-8

#
# schedulesテーブルのmodel
#
class Schedule < ActiveRecord::Base
  attr_accessible :closed_flg, :end_date, :end_time, :entry_resource_id, :lock_version, :memo, :repeat_conditions, :repeat_endless, :repeat_day, :repeat_week, :start_date, :start_time, :title, :update_resource_id
  
  # validate
  validates :title, :length => { :maximum  => 64 }, :presence => true
  validates :memo, :length => { :maximum  => 1024 }
  validates :closed_flg, :length => { :maximum => 1 }, :presence => true
  validates :start_time, :length => { :maximum  => 4 }
  validates :end_time, :length => { :maximum  => 4 }
  validates :repeat_conditions, :length => { :maximum => 1 }
  validates :repeat_week, :length => { :maximum => 1 }
  validates :repeat_day, :length => { :maximum => 2 }
  validates :repeat_endless, :length => { :maximum => 1 }

  #
  # スケジュール取得
  # 指定した日付間、リソースに紐付くスケジュール情報を取得します
  # ==== _Args_
  # [resource_ids]
  #   取得対象リソースIDList
  # [start_date]
  #   取得開始日
  # [end_date]
  #   取得終了日
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.get_schedule_list(resource_ids, start_date, end_date)
    sql = <<-EOS
      select 
        A.*,
        B.resource_id
      from 
        schedules A,
        schedule_conns B
      where
        A.id = B.schedule_id and
        B.resource_id in(:resource_ids) and
        ((:start_date <= A.start_date and A.start_date <= :end_date)
          or (:start_date <= A.end_date and A.end_date <= :end_date)
          or (A.start_date < :start_date and :end_date < A.end_date ))
      order by A.start_date, A.start_time, A.id, B.resource_id
    EOS

    param_hash = {}
    param_hash[:resource_ids] = resource_ids
    param_hash[:start_date] = start_date
    param_hash[:end_date] = end_date
    
    # 直接SQL発行
    SqlHelper::find_by_sql(sql, param_hash, self, SqlHelper::DefaultPagerCondition.new)
    
  end
  
end
