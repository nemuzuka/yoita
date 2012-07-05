# encoding: utf-8

# SQL文組立の際に使用されるmodule
module SqlHelper

  # 定数
  AND = 1
  OR = 2

  # 検索条件結合
  # 項目を追加します
  # 検索条件が未設定の場合、引数の検索条件を戻り値の検索条件とします。
  # 既に検索条件が存在する場合、引数の検索条件を指定Type(未指定の場合、and)で繋ぎます。
  def add_condition(base_condition, add_condition, type=AND)
    
    result_condition = nil
    if base_condition == nil
      # 元の検索条件が未設定の場合、add対象の検索条件をそのまま帰す
      result_condition = add_condition
    else
      # 元の検索条件が何かしら設定されている場合、検索条件を連結
      if type == AND
        result_condition = base_condition.and(add_condition)
      else
        result_condition = base_condition.or(add_condition)
      end
    end
    return result_condition
  end

  # like検索時の文字列置換
  # \→\\
  # %→\%
  # ％→\％
  # _→\_
  # ＿→\_
  def replase_match_string(target)
    if target == nil
      return ""
    end
    
    # 文字列置換(%,_,％,＿,\)
    # \の時だけはブロックを使う形にしています。先頭にしないと、他の文字のエスケープにつけた\もエスケープしてしまいます
    return target.gsub(/\\/){'\\\\'}.gsub(/%/, '\%')
      .gsub(/_/, '\_').gsub(/％/, '\％').gsub(/＿/, '\＿')
  end

  # 検索処理実行
  # where句の有り/無し
  # ページングの有り/無し
  # で発行するSQLを変更します
  def executeSearch(param, model_class, condition, orders)
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
  module_function :executeSearch

  # 改ページが必要な場合の条件
  # total_count トータル件数 => output
  # page 表示ページ番号(1 start) => input
  # per 1ページ辺りの表示件数(nilの場合、全て出力) => input
  class DefaultPagerCondition
    # output
    attr_accessor :total_count, :page, :per
  end

end
