# encoding: utf-8

#
# スケジュール詳細に関するLogic
#
class ScheduleDetailLogic

  #
  # 詳細情報取得
  # idに紐付くスケジュール情報を取得します。
  # idが未設定の場合、newしただけのインスタンスを返します。
  # idが設定されていても該当データが存在しない場合、例外をthrowします
  # 非公開のスケジュールで、ログインユーザが参加していない or 登録していないスケジュールに対しても
  # 該当データ無しの例外をthrowします
  # ==== _Args_
  # [schedule_id]
  #   取得対象のスケジュールID
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleDetailLogic::Detail</i>)
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def get_detail(schedule_id, action_resource_id)

    result = ScheduleDetailLogic::Detail.new
    
    if schedule_id.to_s == ''
      result.schedule = Schedule.new
      result.schedule_conn_set = SortedSet.new
    else
      schedule = Schedule.find_by_id(schedule_id)
      if schedule == nil
        raise CustomException::NotFoundException.new
      end
      result.schedule = schedule
      
      result.schedule_conn_set = SortedSet.new
      schedule_conns = ScheduleConn.find_by_schedule_id(schedule_id)
      schedule_conns.each do |target|
        result.schedule_conn_set.add(target[:resource_id])
      end
      
      if schedule[:closed_flg] == '1'
        # 非公開のスケジュールの場合
        if result.schedule_conn_set.include?(action_resource_id.to_i) == false && 
          schedule[:entry_resource_id] != action_resource_id.to_i
          # 参加リソースに含まれず、かつスケジュール作成者でない場合、例外をthrowする
          raise CustomException::NotFoundException.new
        end
      end
    end

    return result
  end
  
  #
  # スケジュール詳細情報
  #
  class Detail
    # スケジュール
    attr_accessor :schedule
    
    # スケジュール関連リソースIDSet
    attr_accessor :schedule_conn_set
  end
  
end