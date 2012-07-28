# encoding: utf-8

#
# スケジュールフォローに関するLogic
#
class ScheduleFollowLogic
  
  #
  # フォロー一覧取得
  # ==== _Args_
  # [schedule_id]
  #   取得対象スケジュールID
  # [action_resource_id]
  #   ログインユーザリソースID
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  # <i>ScheduleFollowLogic::ScheduleFollow</i>のList
  #
  def get_follow_list(schedule_id, action_resource_id)
    
    # スケジュール情報を取得
    logic = ScheduleDetailLogic.new
    detail = logic.get_detail(schedule_id, action_resource_id)
    schedule = detail.schedule
    
    # スケジュールフォロー情報を取得
    list = ScheduleFollow.find_by_schedule_id(schedule_id)

    # スケジュールに紐付くリソース情報を取得
    resource_id_set = SortedSet.new
    list.each do |target|
      resource_id_set.add(target[:entry_resource_id])
    end
    resource_logic = ResourceLogic.new
    resrouce_hash = resource_logic.get_resources_hash(resource_id_set)
    
    # 戻りListを作成
    ret_list = []
    # スケジュールの作成者であれば全てのフォローを削除可能
    entry_user = false
    if schedule[:entry_resource_id] == action_resource_id
      entry_user = true
    end
    list.each do |target|
      entity = ScheduleFollowEntity.new
      entity.schedule_follow = target
      entity.entry_resource_name = ""
      resource = resrouce_hash[target[:entry_resource_id]]
      if resource != nil
        entity.entry_resource_name = resource[:name]
      end
      entity.entry_time = DateHelper::get_formated_time(target[:created_at], "%m/%d %H:%M")
      entity.delete = false
      if entry_user == true || target[:entry_resource_id] == action_resource_id
        entity.delete = true
      end
      ret_list.push(entity)
    end
    return ret_list
  end
  
  #
  # スケジュールFollowの表示用データ保持クラス
  #
  class ScheduleFollowEntity
    # スケジュールフォロー
    # see. <i>Schedule<i>
    attr_accessor :schedule_follow
    
    # 登録者名
    attr_accessor :entry_resource_name
    
    # 登録日時(M/D HH:mm形式)
    attr_accessor :entry_time
    
    # 削除可能なフォローの場合、true
    attr_accessor :delete
  end
  
end
