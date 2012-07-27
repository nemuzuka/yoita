# encoding: utf-8
require "model"

#
# resourcesテーブルのmodel
#
class Resource < ActiveRecord::Base
  attr_accessible :entry_resource_id, :lock_version, :memo, :name, :resource_type, :sort_num, :update_resource_id

  # validates
  validates :resource_type, :length => { :is => 3 }
  validates :name, :length => { :maximum  => 128 }, :presence => true
  validates :memo, :length => { :maximum  => 1024 }

  #
  # json変換時処理.
  # json変換時に出力する項目を設定します。
  #
  def as_json(options={})
    options[:except] ||= [:created_at, :updated_at, 
      :entry_resource_id, :update_resource_id, :sort_num]
    super(options)
  end

  #
  # 検索条件に合致するレコードを抽出.
  # 検索条件として設定されている項目に対してのみWhere句に設定します。ページャ用の設定がされている場合、ページング処理を行います
  # ==== _Args_
  # [param]
  #   検索条件パラメータ(see. <i>Resource::SearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_conditions(param)
    
    sql = <<-EOS
      select 
        * 
      from 
        resources
      where
        1 = 1
    EOS
    
    param_hash = {}
    # 名称(中間一致)
    if param.name.to_s != ''
      sql << " and name like :name "
      param_hash[:name] = "%" + SqlHelper.replase_match_string(param.name) + "%"
    end

    # 区分(一致)
    if param.resource_type.to_s != ''
      sql << " and resource_type = :resource_type "
      param_hash[:resource_type] = param.resource_type
    end
    
    # 指定id
    if param.ids != nil && param.ids.length != 0
      sql << " and id in (:ids) "
      param_hash[:ids] = param.ids
    end
    
    # ソート順(パラメータで変更するかもしれないけど、とりあえず固定で)
    sql << " order by sort_num, id "
    
    # 直接SQL発行
    SqlHelper::find_by_sql(sql, param_hash, self, param)
  end

  #
  # ソート順更新.
  # 指定したidのlistの順番にソート順を更新します。idとリソース区分が合致するレコードが存在しない場合でも
  # エラーにはなりません。
  # ==== _Args_
  # [ids]
  #   更新対象idList。この順番にソート順を1から採番します
  # [resource_type]
  #   リソース区分
  #
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

  #
  # リソース情報のHash作成
  # ==== _Args_
  # [resource_ids]
  #   リソースIDList
  # ==== _Return_
  # keyがリソースID(string)、valueが<i>Resource</i>のHash
  # ※<i>ActiveSupport::OrderedHash</i>で返すので、順番を保持します
  #
  def self.create_resource_hash(resource_ids)
    search_param = Resource::SearchParam.new
    search_param.ids = resource_ids
    
    list = self.find_by_conditions(search_param)
    hash = ActiveSupport::OrderedHash.new
    list.each do |target|
      hash[target[:id]] = target
    end
    return hash
  end

  #
  # Resourceの検索条件のパラメータclass
  #
  class SearchParam < Model::SearchParam
    # 名称
    attr_accessor :name
    # リソース区分
    attr_accessor :resource_type
    # idのList
    attr_accessor :ids
  end

end