# encoding: utf-8

#
# schedule_connsテーブルのmodel
#
class ScheduleConn < ActiveRecord::Base
  attr_accessible :resource_id, :schedule_id

  #
  # スケジュール関連データ取得.
  # 指定したスケジュールIDに紐付くスケジュール関連データを取得します
  # ==== _Args_
  # [schedule_id]
  #   取得対象スケジュールID
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_schedule_id(schedule_id)
    schedule_conns = Arel::Table.new :schedule_conns
    condition = SqlHelper.add_condition(
      nil,
      schedule_conns[:schedule_id].eq(schedule_id))
    orders = [schedule_conns[:id]];
    self.where(condition).order(orders)
  end

  #
  # スケジュール関連データ削除.
  # 指定したスケジュールIDに紐付くスケジュール関連データを削除します
  # ==== _Args_
  # [schedule_id]
  #   削除対象スケジュールID
  # 
  def self.delete_by_schedule_id(schedule_id)

    # 削除条件の設定
    schedule_conns = Arel::Table.new :schedule_conns
    condition = SqlHelper.add_condition(
      nil,
      schedule_conns[:schedule_id].eq(schedule_id))
    # delete文発行
    self.delete_all(condition)
  end

  #
  # スケジュール関連データ削除.
  # 指定したリソースIDに紐付くスケジュール関連データを削除します
  # ==== _Args_
  # [resource_id]
  #   削除対象リソースID
  # 
  def self.delete_by_resource_id(resource_id)

    # 削除条件の設定
    schedule_conns = Arel::Table.new :schedule_conns
    condition = SqlHelper.add_condition(
      nil,
      schedule_conns[:resource_id].eq(resource_id))
    # delete文発行
    self.delete_all(condition)
  end

  #
  # スケジュール関連データ登録.
  # 指定したデータを登録します
  # ==== _Args_
  # [schedule_id]
  #   登録対象スケジュールID
  # [resource_list]
  #   登録対象リソースIDList
  #
  def self.insert_conn_list(schedule_id, resource_list)
    resource_list.each do |target|
      schedule_conns = self.new
      schedule_conns[:schedule_id] = schedule_id
      schedule_conns[:resource_id] = target
      schedule_conns.save!
    end
  end

end
