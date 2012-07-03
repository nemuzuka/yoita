# encoding: utf-8

# SQL文組立の際に使用されるmodule
module SqlHelper

  # 検索条件結合
  # 項目を追加します
  # 検索条件が未設定の場合、引数の検索条件を戻り値の検索条件とします。
  # 既に検索条件が存在する場合、引数の検索条件をandで繋ぎます。
  def add_condition(base_condition, add_condition)
    
    result_condition = nil
    if base_condition == nil
      # 元の検索条件が未設定の場合、add対象の検索条件をそのまま帰す
      result_condition = add_condition
    else
      # 元の検索条件が何かしら設定されている場合、andで検索条件を連結
      result_condition = base_condition.and(add_condition)
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

  module_function :add_condition
  module_function :replase_match_string

end
