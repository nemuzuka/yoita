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

      # フォロー削除可能の設定
      entity.delete_follow = false
      if entry_user == true || target[:entry_resource_id] == action_resource_id
        entity.delete_follow = true
      end
      ret_list.push(entity)
    end
    return ret_list
  end
  
  #
  # スケジュールフォロー追加
  # ==== _Args_
  # [params]
  #   登録情報
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  #
  def save(params, action_resource_id)
    
    schedule_id = params[:schedule_follow][:schedule_id]
    # スケジュールの存在チェック、参照チェック
    logic = ScheduleDetailLogic.new
    logic.get_detail(schedule_id, action_resource_id)
    
    # スケジュールフォローの登録
    schedule_follow = ScheduleFollow.new(params[:schedule_follow])
    schedule_follow[:entry_resource_id] = action_resource_id
    schedule_follow[:update_resource_id] = action_resource_id
    
    begin
      schedule_follow.save!
    rescue ActiveRecord::RecordInvalid => e
      raise CustomException::ValidationException.new(e.record.errors.full_messages)
    end
  end
  
  #
  # スケジュールフォロー削除
  # ==== _Args_
  # [schedule_id]
  #   スケジュールID
  # [schedule_follow_id]
  #   スケジュールフォローID
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  #
  def delete(schedule_id, schedule_follow_id, action_resource_id)
    # スケジュールの存在チェック、参照チェック
    logic = ScheduleDetailLogic.new
    schedule_detail = logic.get_detail(schedule_id, action_resource_id)
    
    schedule_follow = ScheduleFollow.find_by_id(schedule_follow_id)
    if schedule_follow == nil
      raise CustomException::NotFoundException
    end
    
    # フォローを削除する権限が無ければ、エラー
    schedule = schedule_detail.schedule
    if schedule[:entry_resource_id] != action_resource_id && 
      schedule_follow[:entry_resource_id] != action_resource_id

      raise CustomException::NotFoundException
    end
    
    schedule_follow.destroy
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
    attr_accessor :delete_follow
  end
  
end
