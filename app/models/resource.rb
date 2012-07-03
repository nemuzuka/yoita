# encoding: utf-8

# Resourcesテーブルのmodel
class Resource < ActiveRecord::Base
  attr_accessible :entry_resource_id, :lock_version, :memo, :name, :resource_type, :sort_num, :update_resource_id

  # validates
  validates :resource_type, :length => { :is => 3 }
  validates :name, :length => { :maximum  => 128 } ,:presence => true
  validates :memo, :length => { :maximum  => 1024 }

  # 検索条件に合致するレコードを抽出
  def self.find_by_conditions(param)
    
    resources = Arel::Table.new :resources
    
    # 検索条件をパラメータによって動的に変更する
    condition = nil
    # 名称(中間一致)
    if param.name != nil && param.name != ''
      condition = SqlHelper.add_condition(
        condition, 
        resources[:name].matches("%" + SqlHelper.replase_match_string(param.name) + "%"))
    end

    # 区分(必須)
    if param.resource_type != nil && param.resource_type != ''
      condition = SqlHelper.add_condition(
        condition, 
        resources[:resource_type].eq(param.resource_type))
    end
    
    # 指定id
    if param.ids != nil && param.ids.length != 0
      condition = SqlHelper.add_condition(
        condition, 
        resources[:id].eq_any(param.ids))
    end
    
    # ソート順(パラメータで変更するかもしれないけど、とりあえず固定で)
    orders = [resources[:sort_num], resources[:id]];
    
    # 設定条件次第でSQL発行
    if condition != nil
      self.where(condition).order(orders).all
    else
      self.order(orders).all
    end
  end

  # ソート順更新
  def self.update_sort_num(ids, resource_type)
    if ids == nil || ids.length == 0
      return
    end
    
    sort_num = 1
    ids.each do |id|
      
      # 指定idのソート順を更新
      self.update_all(["sort_num = ?", sort_num], 
        ["id = ? and resource_type = ?", id, resource_type])
      sort_num = sort_num + 1
    end
  end

end

# 検索条件のパラメータclass
class ResourceSearchParam
  attr_accessor :name, :resource_type, :ids
end
