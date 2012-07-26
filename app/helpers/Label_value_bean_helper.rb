# encoding: utf-8

#
# select構成情報加工の際に使用されるヘルパーmodule
#
module LabelValueBeanHelper
  module_function

  #
  # グループ情報追加
  # グループが1件以上存在する場合、区切り文字を設定します
  # ==== _Args_
  # [target_list]
  #   登録先List
  # [group_list]
  #   登録対象List
  # [label]
  #   区切り文字ラベル(初期値は"--")
  #
  def add_group(target_list, group_list, label = "--")
    if group_list.length != 0
      target_list.push(Entity::LabelValueBean.new("",label))
    end
    group_list.each do |target|
      target_list.push(Entity::LabelValueBean.new(target[:id], target[:name]))
    end
  end

end
