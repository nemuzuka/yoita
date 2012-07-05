# encoding: utf-8

#
#SQL文組立の際に使用されるヘルパーmodule
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
  # ==== Args
  # _base_condition_ :: 結合先検索条件
  # _add_condition_ :: 結合対象検索条件
  # _type_ :: 指定Type(未指定の場合、AND条件  see. <i>SqlHelper.AND_JOIN</i> <i>SqlHelper.OR_JOIN</i> )
  # ==== Return
  # 結合後検索条件
  #
  def add_condition(base_condition, add_condition, type=AND_JOIN)
    
    result_condition = nil
    if base_condition == nil
      # 元の検索条件が未設定の場合、add対象の検索条件をそのまま帰す
      result_condition = add_condition
    else
      # 元の検索条件が何かしら設定されている場合、検索条件を連結
      if type == AND_JOIN
        result_condition = base_condition.and(add_condition)
      else
        result_condition = base_condition.or(add_condition)
      end
    end
    return result_condition
  end
  
  # 
  # like検索時の文字列置換
  # 引数の文字列に対してlike検索ができるように、「\」でエスケープします。
  # \→\\
  # %→\%
  # ％→\％
  # _→\_
  # ＿→\_
  # ==== Args
  # _target_ :: 置換対象文字列
  # ==== Return
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
  # 検索処理実行
  # where句の有り/無し
  # ページングの有り/無し
  # で発行するSQLを変更します
  # ==== Args
  # _param_ :: <i>SqlHelper::DefaultPagerCondition</i>のサブクラスのインスタンスである必要があります。
  # _model_class_ :: modelクラス
  # _condition_ :: 検索条件
  # _orders_ :: ソート順(必須)
  # ==== Return
  # 検索結果
  #
  def execute_search(param, model_class, condition, orders)
    # 設定条件次第でSQL発行
    result = nil
    target = model_class
    if condition != nil
      target = model_class.where(condition)
    end
    
    if param.per == nil
      # ページングの指定が無い場合
      result = target.order(orders).all
      param.total_count = result.length
    else
      # ページングの指定がある場合
      result = target.order(orders).page(param.page).per(param.per)
      param.total_count = result.total_count
    end

    return result;
  end

  module_function :add_condition
  module_function :replase_match_string
  module_function :execute_search

  #
  #改ページが必要な場合の条件
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
