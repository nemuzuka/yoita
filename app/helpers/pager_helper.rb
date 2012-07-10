# encoding: utf-8

#
# ページリンク文字列を作成するヘルパー
#
module PagerHelper
  
  # ページ省略時の文字列
  CONTINUE_STR = "..."
  
  #
  # ページリンク文字列作成.
  # リンク文字列を生成します
  # ==== _Args_
  # [default_pager_condition]
  #   ページリンク生成条件。<i>SqlHelper::DefaultPagerCondition</i>のサブクラスのインスタンスである必要があります。
  # [function_name]
  #   ページリンククリック時に呼ばれるjavascriptの関数名
  # [app_path]
  #   ページリンククリック時に呼ばれるpath名
  # ==== _Return_
  # ページリンク文字列(そのままhtml出力することを想定)
  # 
  def crate_page_link(default_pager_condition, function_name, app_path)
    
    if default_pager_condition.total_count == nil || default_pager_condition.total_count == 0 || 
      default_pager_condition.per == nil || default_pager_condition.per == 0 ||
      default_pager_condition.page == nil || default_pager_condition.page == 0
      return ""
    end
    
    # トータルページ数を算出
    total_page_num = default_pager_condition.total_count / default_pager_condition.per
    mod_num = default_pager_condition.total_count % default_pager_condition.per
    if mod_num != 0
      total_page_num = total_page_num + 1
    end
    
    current_page_num = default_pager_condition.page
    
    # ページリンクの構成情報を作成して、アンカーリンク文字列を生成
    page_info_list = create_page_info_list(total_page_num, current_page_num)
    links = []
    page_info_list.each do |target|
      
      link_str = nil
      if target.link?
        link_str = "<a class='pagelink' title='Page %d' href='javascript:void(0)' " <<
          "onclick='%s(%d, \"%s\"); return false;'>%s</a>"
        link_str = link_str % ([target.view_str, function_name, target.view_str, app_path, target.view_str])
      else
        link_str = "<span class='pagelink'><b>%s</b></span>"
        link_str = link_str % ([target.view_str])
      end
      links.push(link_str)
    end
    
    return links * " "
  end
  
  # これ以降はprotected
  protected

    #
    # ページリンク構成情報作成
    # 現在のページに対して前後のページが存在するかを判断してページ情報を作成します。
    # 2ページ以上前後するページが存在する場合、「...」で置き換え、
    # 1ページ目または最終ページのリンクを表示します
    # ==== _Args_
    # [total_page_num]
    #   全取得件数と1ページあたりの表示件数を元に算出した、トータルページ数
    # [current_page_num]
    #   表示対象ページ数(1から始まる)
    # ==== _Return_
    # ページリンク構成List
    # 
    def create_page_info_list(total_page_num, current_page_num)
      result_list = []
      
      # 自分の情報を登録
      result_list.push(LinkInfo.new(current_page_num, false))
      
      # 自分のページの前の情報が存在する場合、登録
      before_page_num = current_page_num - 1
      if before_page_num > 0
        # 先頭の要素に追加
        result_list.unshift(LinkInfo.new(before_page_num, true))
        
        # さらに前のページが存在する場合
        before2_page_num = before_page_num - 1
        if before2_page_num > 0
          if before2_page_num != 1
            # 先頭のページでない場合、「...」を設定する
            result_list.unshift(LinkInfo.new(CONTINUE_STR, false))
          end
          
          # 1ページ目のリンクを作成する
          result_list.unshift(LinkInfo.new(1, true))
        end
      end
      
      # 自分のページの後の情報が存在する場合、登録
      after_page_num = current_page_num + 1
      if after_page_num <= total_page_num
        # 要素の最後に追加
        result_list.push(LinkInfo.new(after_page_num, true))
  
        # 更に次のページが存在する場合
        after2_page_num = after_page_num + 1
        if after2_page_num <= total_page_num
          # 最後のページでない場合、「...」を設定する
          if after2_page_num != total_page_num
            result_list.push(LinkInfo.new(CONTINUE_STR, false))
          end
          # 最終ページのリンクを作成する
          result_list.push(LinkInfo.new(total_page_num, true))
        end
      end
      
      return result_list
    end
    
    
    #
    # アンカーリンク表示情報
    #
    class LinkInfo
      # 表示文字列
      attr_accessor :view_str
      # リンク表示区分
      attr_accessor :link
      
      #
      # コンストラクタ
      # ==== _Args_
      # [view_str]
      #   表示文字列
      # [link]
      #   リンク表示する項目の場合、true/ラベル表示の場合、false
      #
      def initialize(view_str, link)
        @view_str = view_str
        @link = link
      end
      
      #
      # リンク表示する項目か？
      # ==== _Return_
      # リンク表示する場合、true
      #
      def link?
        return link
      end
    end

  module_function :crate_page_link, :create_page_info_list
end