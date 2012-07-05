# encoding: utf-8
require 'test_helper'

class PagerHelperTest < ActionView::TestCase
  
  include PagerHelper
  
  # ページャーによるリンク文字列のテスト
  test "pager_condition" do
    
    # トータル件数が0件の場合、リンク文字列は表示しない
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.total_count = 0
    assert_equal crate_page_link(pager_condition, "func1", "/hige"), ""
    
    # 1ページ辺りの表示件数が0件の場合、リンク文字列は表示しない
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.per = 0
    assert_equal crate_page_link(pager_condition, "func1", "/hige"), ""
    
    # ページ辺り10件で結果1件、一覧表示は1ページ目からの場合
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.total_count = 1
    pager_condition.per = 10
    pager_condition.page = 1
    assert_equal crate_page_link(pager_condition, "func1", "/hige"), 
      "<span class='pagelink'><b>1</b></span>"

    # ページ辺り10件で結果11件、一覧表示は2ページ目からの場合
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.total_count = 11
    pager_condition.per = 10
    pager_condition.page = 2
    assert_equal crate_page_link(pager_condition, "func1", "/hige"), 
      "<a class='pagelink' title='Page 1' href='javascript:void(0)' onclick='func1(1, \"/hige\"); return false;'>1</a> <span class='pagelink'><b>2</b></span>"
    
    # ページ辺り10件で結果11件、一覧表示は3ページ目からの場合
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.total_count = 11
    pager_condition.per = 10
    pager_condition.page = 3
    assert_equal crate_page_link(pager_condition, "func1", "/hige"), 
      "<a class='pagelink' title='Page 1' href='javascript:void(0)' onclick='func1(1, \"/hige\"); return false;'>1</a> <a class='pagelink' title='Page 2' href='javascript:void(0)' onclick='func1(2, \"/hige\"); return false;'>2</a> <span class='pagelink'><b>3</b></span>"
  end
  
  # リンク情報作成のテスト
  test "create_page_info_list_next" do
    # トータル1ページで1ページ目表示
    # 1
    actual = create_page_info_list(1, 1)
    assert_equal actual.length, 1
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, false
    
    # トータル2ページで1ページ目表示
    # 1 <a>2</a>
    actual = create_page_info_list(2, 1)
    assert_equal actual.length, 2
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, false
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true

    # トータル3ページで1ページ目表示
    # 1 <a>2</a> <a>3</a>
    actual = create_page_info_list(3, 1)
    assert_equal actual.length, 3
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, false
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, true

    # トータル4ページで1ページ目表示
    # 1 <a>2</a> ... <a>4</a>
    actual = create_page_info_list(4, 1)
    assert_equal actual.length, 4
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, false
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true
    assert_equal actual[2].view_str, "..."
    assert_equal actual[2].link, false
    assert_equal actual[3].view_str, 4
    assert_equal actual[3].link, true

    # トータル5ページで1ページ目表示
    # 1 <a>2</a> ... <a>5</a>
    actual = create_page_info_list(5, 1)
    assert_equal actual.length, 4
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, false
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true
    assert_equal actual[2].view_str, "..."
    assert_equal actual[2].link, false
    assert_equal actual[3].view_str, 5
    assert_equal actual[3].link, true
  end

  # リンク情報作成のテスト
  test "create_page_info_list_prev" do
    
    # トータル2ページで2ページ目表示
    # <a>1</a> 2
    actual = create_page_info_list(2, 2)
    assert_equal actual.length, 2
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, false

    # トータル3ページで3ページ目表示
    # <a>1</a> <a>2</a> 3
    actual = create_page_info_list(3, 3)
    assert_equal actual.length, 3
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, false

    # トータル4ページで4ページ目表示
    # <a>1</a> ... <a>3</a> 4
    actual = create_page_info_list(4, 4)
    assert_equal actual.length, 4
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, "..."
    assert_equal actual[1].link, false
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, true
    assert_equal actual[3].view_str, 4
    assert_equal actual[3].link, false
    
    # トータル5ページで5ページ目表示
    # <a>1</a> ... <a>4</a> 5
    actual = create_page_info_list(5, 5)
    assert_equal actual.length, 4
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, "..."
    assert_equal actual[1].link, false
    assert_equal actual[2].view_str, 4
    assert_equal actual[2].link, true
    assert_equal actual[3].view_str, 5
    assert_equal actual[3].link, false
    
  end
  
  # リンク情報作成のテスト
  test "create_page_info_list_multiple" do
    
    # トータル3ページで2ページ目表示
    # <a>1</a> 2 <a>3</a>
    actual = create_page_info_list(3, 2)
    assert_equal actual.length, 3
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, false
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, true

    # トータル5ページで3ページ目表示
    # <a>1</a> <a>2</a> 3 <a>4</a> <a>5</a>
    actual = create_page_info_list(5, 3)
    assert_equal actual.length, 5
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, 2
    assert_equal actual[1].link, true
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, false
    assert_equal actual[3].view_str, 4
    assert_equal actual[3].link, true
    assert_equal actual[4].view_str, 5
    assert_equal actual[4].link, true

    # トータル7ページで4ページ目表示
    # <a>1</a> ... <a>3</a> 4 <a>5</a> ... <a>7</a>
    actual = create_page_info_list(7, 4)
    assert_equal actual.length, 7
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, "..."
    assert_equal actual[1].link, false
    assert_equal actual[2].view_str, 3
    assert_equal actual[2].link, true
    assert_equal actual[3].view_str, 4
    assert_equal actual[3].link, false
    assert_equal actual[4].view_str, 5
    assert_equal actual[4].link, true
    assert_equal actual[5].view_str, "..."
    assert_equal actual[5].link, false
    assert_equal actual[6].view_str, 7
    assert_equal actual[6].link, true

    # トータル9ページで5ページ目表示
    # <a>1</a> ... <a>4</a> 5 <a>6</a> ... <a>9</a>
    actual = create_page_info_list(9, 5)
    assert_equal actual.length, 7
    assert_equal actual[0].view_str, 1
    assert_equal actual[0].link, true
    assert_equal actual[1].view_str, "..."
    assert_equal actual[1].link, false
    assert_equal actual[2].view_str, 4
    assert_equal actual[2].link, true
    assert_equal actual[3].view_str, 5
    assert_equal actual[3].link, false
    assert_equal actual[4].view_str, 6
    assert_equal actual[4].link, true
    assert_equal actual[5].view_str, "..."
    assert_equal actual[5].link, false
    assert_equal actual[6].view_str, 9
    assert_equal actual[6].link, true
  end

end
