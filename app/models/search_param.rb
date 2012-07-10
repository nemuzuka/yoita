# encoding: utf-8

#
# 検索条件のパラメータclass
#
class SearchParam < SqlHelper::DefaultPagerCondition
    # 検索ボタンを押下している場合、true(input)
    attr_accessor :click_search
end
