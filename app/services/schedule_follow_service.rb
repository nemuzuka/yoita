# encoding: utf-8
require "constants"
require "service"
require "model"

#
# スケジュールFollowに対するService
#
class ScheduleFollowService < Service::Base
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
    transaction_handler do
      logic = ScheduleFollowLogic.new
      logic.get_follow_list(schedule_id, action_resource_id)
    end
  end

  #
  # スケジュールフォロー追加
  # ==== _Args_
  # [params]
  #   登録情報
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Return_
  # 対象レコード
  #
  def save(params, action_resource_id)
    transaction_handler do
      logic = ScheduleFollowLogic.new
      logic.save(params, action_resource_id)
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
    transaction_handler do
      logic = ScheduleFollowLogic.new
      logic.delete(schedule_id, schedule_follow_id, action_resource_id)
    end
  end
  
end
