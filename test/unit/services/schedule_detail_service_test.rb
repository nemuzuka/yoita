# encoding: utf-8
require 'test_helper'
require "constants"

# ScheduleDetailServiceのテストクラス
class ScheduleDetailServiceTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_schedule_logic

  test "get_detailのテスト 新規登録時 デフォルトユーザグループ設定なし、ユーザリソース指定" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    service = ScheduleDetailService.new
    actual = service.get_detail('', "2011/12/20", "100003", user_info)
    
    actual_schedule = actual.schedule
    assert_equal actual_schedule[:id], nil
    assert_equal actual_schedule[:start_date], Date.strptime("2011/12/20", "%Y/%m/%d")
    assert_equal actual_schedule[:end_date], Date.strptime("2011/12/20", "%Y/%m/%d")
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, ""
    assert_equal actual.entry_resource_name, ""
    assert_equal actual.update_resource_name, ""
    assert_equal actual.entry_time, ""
    assert_equal actual.update_time, ""
    
    # スケジュール参加ユーザリソース関連
    # パラメータのリソースが初期情報として設定される
    actual_schedule_user_conn_list = actual.schedule_user_conn_list
    assert_equal actual_schedule_user_conn_list.length, 1
    assert_equal actual_schedule_user_conn_list[0].key, 100003
    assert_equal actual_schedule_user_conn_list[0].value, "ユーザB"
    
    # スケジュール参加設備リソース関連
    actual_schedule_facilities_conn_list = actual.schedule_facilities_conn_list
    assert_equal actual_schedule_facilities_conn_list.length, 0
    
    # 全ユーザグループList
    actual_user_group_list = actual.user_group_list
    assert_equal actual_user_group_list.length, 5
    assert_equal actual_user_group_list[0].key, ""
    assert_equal actual_user_group_list[1].key, -1
    assert_equal actual_user_group_list[2].key, -3
    assert_equal actual_user_group_list[3].key, 100001
    assert_equal actual_user_group_list[4].key, 100005

    # ユーザグループ選択値
    # デフォルトユーザグループの設定が無いので、全てのユーザ
    assert_equal actual.selected_user_group, -1
    
    # ユーザグループ選択値に紐付くリソース情報
    # 全てのユーザに紐付くリソース情報
    actual_user_group_conn_list = actual.user_group_conn_list
    assert_equal actual_user_group_conn_list.length, 3
    assert_equal actual_user_group_conn_list[0].key, 100002
    assert_equal actual_user_group_conn_list[1].key, 100003
    assert_equal actual_user_group_conn_list[2].key, 100004
    
    # 全設備グループList
    actual_facilities_group_list = actual.facilities_group_list
    assert_equal actual_facilities_group_list.length, 3
    assert_equal actual_facilities_group_list[0].key, ""
    assert_equal actual_facilities_group_list[1].key, -2
    assert_equal actual_facilities_group_list[2].key, 100006
    
    # 設備グループ選択値
    # 1件目の設備グループが選択値
    assert_equal actual.selected_facilities_group, 100006
    
    # 設備グループ選択値に紐付くリソース情報
    actual_facilities_group_conn_list = actual.facilities_group_conn_list
    assert_equal actual_facilities_group_conn_list.length, 2
    assert_equal actual_facilities_group_conn_list[0].key, 100007
    assert_equal actual_facilities_group_conn_list[1].key, 100008
  end

  test "get_detailのテスト 新規登録時 デフォルトユーザグループ設定あり、設備リソース指定" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = 100001
    service = ScheduleDetailService.new
    actual = service.get_detail('', "2011/12/20", "100008", user_info)
        
    # スケジュール参加ユーザリソース関連
    actual_schedule_user_conn_list = actual.schedule_user_conn_list
    assert_equal actual_schedule_user_conn_list.length, 0
    
    # スケジュール参加設備リソース関連
    # パラメータのリソースが初期情報として設定される
    actual_schedule_facilities_conn_list = actual.schedule_facilities_conn_list
    assert_equal actual_schedule_facilities_conn_list.length, 1
    assert_equal actual_schedule_facilities_conn_list[0].key, 100008
    assert_equal actual_schedule_facilities_conn_list[0].value, "設備B"
    
    # ユーザグループ選択値
    # デフォルトユーザグループの設定値
    assert_equal actual.selected_user_group, 100001
    
    # ユーザグループ選択値に紐付くリソース情報
    actual_user_group_conn_list = actual.user_group_conn_list
    assert_equal actual_user_group_conn_list.length, 4
    assert_equal actual_user_group_conn_list[0].key, 100001
    assert_equal actual_user_group_conn_list[1].key, 100002
    assert_equal actual_user_group_conn_list[2].key, 100003
    assert_equal actual_user_group_conn_list[3].key, 100004
  end

  test "get_detailのテスト 詳細 非繰り返し 開始日=終了日 時刻設定なし" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    service = ScheduleDetailService.new
    actual = service.get_detail('10001', "2011/12/20", "100003", user_info)
    
    actual_schedule = actual.schedule
    assert_equal actual_schedule[:id], 10001
    assert_equal actual_schedule[:start_date], Date.strptime("2010/07/19", "%Y/%m/%d")
    assert_equal actual_schedule[:end_date], Date.strptime("2010/07/19", "%Y/%m/%d")
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "2010年07月19日"
    assert_equal actual.entry_resource_name, "ユーザA"
    assert_equal actual.update_resource_name, "ユーザB"
    assert_equal actual.entry_time, "2010/01/02 12:34"
    assert_equal actual.update_time, "2010/07/10 23:45"
    
    # スケジュール参加ユーザリソース関連
    actual_schedule_user_conn_list = actual.schedule_user_conn_list
    assert_equal actual_schedule_user_conn_list.length, 2
    assert_equal actual_schedule_user_conn_list[0].key, 100001
    assert_equal actual_schedule_user_conn_list[1].key, 100003
    
    # スケジュール参加設備リソース関連
    actual_schedule_facilities_conn_list = actual.schedule_facilities_conn_list
    assert_equal actual_schedule_facilities_conn_list.length, 0
  end

  test "get_detailのテスト 詳細 非繰り返し 開始日=終了日 時刻設定あり" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10002', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "2010年07月20日 09:00 〜 09:15"
  end

  test "get_detailのテスト 詳細 非繰り返し 開始日≠終了日 時刻設定有り" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10004', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "2010年07月22日 15:00  〜 2010年07月24日 13:00"
  end

  test "get_detailのテスト 詳細 繰り返し 毎日" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10005', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎日 10:00 〜 13:00 (2010年08月24日 まで)"
  end

  test "get_detailのテスト 詳細 繰り返し 毎日(土日を除く)" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10006', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎日(土日を除く) (2010年09月10日 まで)"
  end

  test "get_detailのテスト 詳細 繰り返し 毎週月曜日" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10007', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎週 月曜日 (2010年10月10日 まで)"
  end

  test "get_detailのテスト 詳細 繰り返し 毎月8日" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10008', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎月 8日 (2010年11月10日 まで)"
  end

  test "get_detailのテスト 詳細 繰り返し 毎月月末" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10009', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎月 月末 (2010年12月31日 まで)"
  end

  test "get_detailのテスト 詳細 繰り返し 時刻指定あり" do
    user_info = Entity::UserInfo.new
    user_info.default_user_group = nil
    user_info.resource_id = 100003
    service = ScheduleDetailService.new
    actual = service.get_detail('10010', nil, nil, user_info)
    
    actual_schedule = actual.schedule
    
    # 詳細表示用データの確認
    assert_equal actual.view_date, "毎日 09:30 〜 10:00 (2011年01月18日 まで)"
  end

end
