# encoding: utf-8
require "constants"

#
# user_facilities_group_connテーブルのmodel
#
class UserFacilitiesGroupConn < ActiveRecord::Base
  attr_accessible :child_resource_id, :parent_resource_id

  # validates
  validates :child_resource_id, :presence => true
  validates :parent_resource_id, :presence => true

  #
  # グループ関連データ取得.
  # 指定した親リソースIDに紐付くグループ関連データを取得します
  # ==== _Args_
  # [parent_resource_id]
  #   取得対象親リソースID
  # [include_parent]
  #   戻り値に親リソースIDが子リソースIDのものを含める場合、true(ユーザグループの場合のみ有効)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_parent_id(parent_resource_id, include_parent)
    
    # 検索条件の設定
    sql = <<-EOS
      select 
        * 
      from 
        user_facilities_group_conns
      where
        1 = 1
    EOS
    
    param_hash = {}
    sql << " and parent_resource_id = :parent_resource_id "    
    param_hash[:parent_resource_id] = parent_resource_id

    if include_parent == false
      # 親リソースIDが子リソースIDと指定されているレコードを除外する
      sql << " and child_resource_id != :parent_resource_id "
    end
    
    # ソート順の設定
    sql << " order by id "
    
    param = SqlHelper::DefaultPagerCondition.new
    # SQL発行
    SqlHelper::find_by_sql(sql, param_hash, self, param)

  end

  #
  # グループ関連データ削除.
  # 指定した親リソースIDに紐付くグループ関連データを削除します
  # ==== _Args_
  # [parent_resource_id]
  #   削除対象親リソースID
  # 
  def self.delete_by_parent_id(parent_resource_id)

    # 削除条件の設定
    user_facilities_group_conns = Arel::Table.new :user_facilities_group_conns
    condition = SqlHelper.add_condition(
      nil,
      user_facilities_group_conns[:parent_resource_id].eq(parent_resource_id))
    # delete文発行
    self.delete_all(condition)
  end

  #
  # グループ関連データ削除.
  # 指定した子リソースIDに紐付くグループ関連データを削除します
  # ユーザ、設備が削除された際に呼び出すことを想定しています
  # ==== _Args_
  # [child_resource_id]
  #   削除対象子リソースID
  # 
  def self.delete_by_child_id(child_resource_id)

    # 削除条件の設定
    user_facilities_group_conns = Arel::Table.new :user_facilities_group_conns
    condition = SqlHelper.add_condition(
      nil,
      user_facilities_group_conns[:child_resource_id].eq(child_resource_id))
    # delete文発行
    self.delete_all(condition)
  end

  #
  # グループ関連データ登録.
  # 指定したデータを登録します
  # ==== _Args_
  # [parent_resource_id]
  #   登録対象親リソースID
  # [child_resource_list]
  #   登録対象子リソースIDList
  #
  def self.insert_child_list(parent_resource_id, child_resource_list)
    child_resource_list.each do |target|
      user_facilities_group_conns = self.new
      user_facilities_group_conns[:parent_resource_id] = parent_resource_id
      user_facilities_group_conns[:child_resource_id] = target
      user_facilities_group_conns.save!
    end
  end

  #
  # グループ一覧取得
  # 指定した子リソースIDが所属するグループの一覧を取得します
  # ==== _Args_
  # [child_resource_id]
  #   取得対象リソースID
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_parents_by_child_id(child_resource_id)
    sql = <<-EOS
      select 
        A.name,
        A.id
      from 
        resources A,
        user_facilities_group_conns B
      where
        A.id = B.parent_resource_id
        and B.child_resource_id = :child_resource_id
      order by A.sort_num, A.id
    EOS
    
    param_hash = {}
    param_hash[:child_resource_id] = child_resource_id
    
    param = SqlHelper::DefaultPagerCondition.new
    # SQL発行
    SqlHelper::find_by_sql(sql, param_hash, self, param)
    
  end

end
