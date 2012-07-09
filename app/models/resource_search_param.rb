# encoding: utf-8

#
# Resourceの検索条件のパラメータclass
#
class ResourceSearchParam < SqlHelper::DefaultPagerCondition
  # 名称
  attr_accessor :name
  # リソース区分
  attr_accessor :resource_type
  # idのList
  attr_accessor :ids
end
