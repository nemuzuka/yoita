# encoding: utf-8

#
# schedule_followsテーブルのmodel
#
class ScheduleFollow < ActiveRecord::Base
  attr_accessible :entry_resource_id, :memo, :parent_schedule_follow_id, :schedule_id, :update_resource_id
  
  # validate
  validates :memo, :length => { :maximum  => 1024 }

  #
  # スケジュールフォローデータ取得.
  # 指定したスケジュールIDに紐付くスケジュールフォローデータを取得します
  # ※親スケジュールIDの設定は無視しています
  # ==== _Args_
  # [schedule_id]
  #   取得対象スケジュールID
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_schedule_id(schedule_id)
    schedule_follow = Arel::Table.new :schedule_follows
    condition = SqlHelper.add_condition(
      nil,
      schedule_follow[:schedule_id].eq(schedule_id))
    orders = [schedule_follow[:id]];
    self.where(condition).order(orders)
  end

  #
  # スケジュールフォローデータ削除.
  # 指定したスケジュールIDに紐付くスケジュールフォローデータを削除します
  # ==== _Args_
  # [schedule_id]
  #   削除対象スケジュールID
  # 
  def self.delete_by_schedule_id(schedule_id)

    # 削除条件の設定
    schedule_follow = Arel::Table.new :schedule_follows
    condition = SqlHelper.add_condition(
      nil,
      schedule_follow[:schedule_id].eq(schedule_id))
    # delete文発行
    self.delete_all(condition)
  end

end
