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
    resource_id_set, list, add_comment_follow_is_set = create_set_and_list(list)
    
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
      
      # コメント追加ボタンの表示判断
      entity.add_comment = false
      entity.add_comment = true if add_comment_follow_is_set.include?(target[:id])
      
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

    # コメント追加するボタンを表示するフォローの場合、true
    attr_accessor :add_comment

  end
  
  private
  
    #
    # フォローに紐付くリソースと、フォロー関連を参照してソートを変更します
    # 変更後フォローのソート順は、
    # 親フォロー1
    #   小フォロー1-1
    #   小フォロー1-2
    # 親フォロー2
    #   小フォロー2-1
    # 親フォロー3
    # という関係になります。
    # 親フォロー1[:id] > 親フォロー2[:id]
    # であること、
    # 小フォロー1-1[:id] < 小フォロー1-2[:id]
    # の関係となります。
    # ==== _Args_
    # [list]
    #   <i>ScheduleFollow</i>のList
    # ==== _Return_
    # index:0 リソースIDSet
    # index:1 変更後フォローList<i>ScheduleFollow</i>のList
    # index:2 コメント追加対象フォローIDSet
    #
    def create_set_and_list(list)
      parent_list = []
      child_hash = {}
      resource_id_set = SortedSet.new
      list.each do |target|
        resource_id_set.add(target[:entry_resource_id])
        
        # TOPのフォローか、配下のフォローか設定し分ける
        if target[:parent_schedule_follow_id] == nil
          parent_list.push(target)
        else
          child_list = child_hash[target[:parent_schedule_follow_id]]
          if child_list == nil
            child_list = []
            child_hash[target[:parent_schedule_follow_id]] = child_list
          end
          child_list.unshift(target)
        end
      end
      
      # 戻り値のフォローListと、コメント追加対象フォローIDSet生成
      ret_list = []
      add_comment_follow_is_set = SortedSet.new
      parent_list.each do |target|
        ret_list.push(target)
        # 配下のフォローを追加
        child_list = child_hash[target[:id]]
        if child_list != nil
          ret_list.concat(child_list)
          # 配下のフォローが存在する場合、最後の行
          add_comment_follow_is_set.add(child_list[-1][:id])
        else
          # 配下のフォローが無い場合、親フォローID
          add_comment_follow_is_set.add(target[:id])
        end
      end
      
      return resource_id_set, ret_list, add_comment_follow_is_set
    end
  
end
