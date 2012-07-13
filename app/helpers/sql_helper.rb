# encoding: utf-8

#
# SQL文組立の際に使用されるヘルパーmodule
#
module SqlHelper

  # AND条件
  AND_JOIN = 1
  # OR条件
  OR_JOIN = 2
  
  #
  # 検索条件結合
  # 項目を追加します
  # 結合先検索条件が未設定の場合、結合対象検索条件を戻り値の検索条件とします。
  # 結合先検索条件が設定されている場合、結合対象検索条件を指定Type(未指定の場合、AND条件)で繋ぎます。
  # ==== _Args_
  # [base_condition]
  #   結合先検索条件
  # [target_condition]
  #   結合対象検索条件
  # [type]
  #   指定Type(未指定の場合、AND条件  see. <i>SqlHelper.AND_JOIN</i> <i>SqlHelper.OR_JOIN</i> )
  # ==== _Return_
  # 結合後検索条件
  #
  def add_condition(base_condition, target_condition, type=AND_JOIN)
    
    result_condition = nil
    if base_condition == nil
      # 元の検索条件が未設定の場合、add対象の検索条件をそのまま帰す
      result_condition = target_condition
    else
      # 元の検索条件が何かしら設定されている場合、検索条件を連結
      if type == AND_JOIN
        result_condition = base_condition.and(target_condition)
      else
        result_condition = base_condition.or(target_condition)
      end
    end
    return result_condition
  end
  
  # 
  # like検索時の文字列置換
  # 引数の文字列に対してlike検索ができるように、「\」でエスケープします。
  #   \→\\
  #   %→\%
  #   ％→\％
  #   _→\_
  #   ＿→\_
  # ==== _Args_
  # [target]
  #   置換対象文字列
  # ==== _Return_
  # 置換後文字列
  # 
  def replase_match_string(target)
    if target == nil
      return ""
    end
    
    # 文字列置換(%,_,％,＿,\)
    # \の時だけはブロックを使う形にしています。先頭にしないと、他の文字のエスケープにつけた\もエスケープしてしまいます
    return target.gsub(/\\/){'\\\\'}.gsub(/%/, '\%')
      .gsub(/_/, '\_').gsub(/％/, '\％').gsub(/＿/, '\＿')
  end

  #
  # SQL発行
  # ページングの指定によって、SQLを仕分けます
  # 検索実行後、引数のparam.total_countにトータル件数を設定します。
  # ==== _Args_
  # [sql]
  #   SQL文(find_by_sqlに渡すSQL文です)
  # [param_hash]
  #   SQL文パラメータ(find_by_sqlに渡すパラメータです)
  # [model_class]
  #   modelクラス
  # [pager_condition]
  #   <i>SqlHelper::DefaultPagerCondition</i>のサブクラスのインスタンスである必要があります。
  # ==== _Return_
  # 検索結果
  #
  def find_by_sql(sql, param_hash, model_class, pager_condition)
    
    result = nil
    if pager_condition.per == nil
      # ページングの指定がない場合、そのままsql実行
      result = model_class.find_by_sql([sql, param_hash])
      pager_condition.total_count = result.length
    else
      # トータルページを取得するsqlを発行
      count_sql = "select count(a.*) as count from (" + sql + ") as a"
      result_count = model_class.find_by_sql([count_sql, param_hash])
      pager_condition.total_count = result_count[0][:count]
      
      # limit/offsetを加味してSQL発行
      offset = calcOffset(pager_condition)
      offset_sql = sql + " LIMIT " + pager_condition.per.to_s + " OFFSET " + offset.to_s
      result = model_class.find_by_sql([offset_sql, param_hash])
    end

    return result
  end

  #
  # offset計算
  # 表示対象ページが1ページより小さい場合、1ページ目を表示するとみなします
  # ==== _Args_
  # [pager_condition]
  #   ページャ条件
  # ==== _Return_
  # offset値
  #
  def calcOffset(pager_condition)
    page = pager_condition.page
    page = 1 if page < 1
    
    offset = (page -1) * pager_condition.per
    return offset
  end

  module_function :add_condition, :replase_match_string, :find_by_sql,
    :calcOffset

  #
  # 改ページが必要な場合の条件
  #
  class DefaultPagerCondition
    # トータル件数(output)
    attr_accessor :total_count
    # 表示ページ番号 1から始まる(input)
    attr_accessor :page
    # 1ページ辺りの表示件数 nilの場合、全て出力(input)
    attr_accessor :per
  end

end
