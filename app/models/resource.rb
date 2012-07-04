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
    result = nil
    
    if(param.per == -1)
      # ページングの指定が無い場合
      if condition != nil
        result = self.where(condition).order(orders).all
      else
        result = self.order(orders).all
      end
      param.total_count = result.length
    else
      # ページングの指定がある場合
      if condition != nil
        result = self.where(condition).order(orders).page(param.page).per(param.per)
      else
        result = self.order(orders).page(param.page).per(param.per)
      end
      param.total_count = result.total_count
    end
    return result;
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

# 改ページが必要な場合の条件
# total_count トータル件数 => output
# page 表示ページ番号(0 start) => input
# per 1ページ辺りの表示件数(-1の場合、全て出力) => input
class DefaultPagerCondition
  # output
  attr_accessor :total_count,:page, :per
  
  # 初期値設定
  def after_initialize
    self.per = -1
  end
end

# 検索条件のパラメータclass
class ResourceSearchParam < DefaultPagerCondition
  attr_accessor :name, :resource_type, :ids
end
