module ApplicationHelper
  # 改ページが必要な場合の条件
  # total_count トータル件数 => output
  # page 表示ページ番号(1 start) => input
  # per 1ページ辺りの表示件数(nilの場合、全て出力) => input
  class DefaultPagerCondition
    # output
    attr_accessor :total_count,:page, :per
  end

end
