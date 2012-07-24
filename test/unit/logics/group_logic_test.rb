# encoding: utf-8
require 'test_helper'
require "constants"

# GroupLogicのテストクラス
class GroupLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_user_facilities_group_conn
  
  #
  # saveメソッド-更新のテスト
  # ユーザグループ
  #
  test "save" do

    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 4

    params = {
      :resource => {
        :id => 100001,
        :resource_type => "003",
        :name => "更新対象ユーザグループ",
        :memo => "メモらしいにょ",
        :lock_version => "0"
      },
      :child_ids => ["100004"]
    }
    
    logic = GroupLogic.new
    logic.save(params, ResourceType::USER_GROUP, 4989)
    
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0].parent_resource_id, 100001
    assert_equal actual_list[0].child_resource_id, 100001
    assert_equal actual_list[1].parent_resource_id, 100001
    assert_equal actual_list[1].child_resource_id, 100004
    
  end

  #
  # saveメソッド-更新のテスト
  # ユーザグループ
  # ユーザでないリソース、登録されていないリソースID指定
  #
  test "save2" do

    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 4

    params = {
      :resource => {
        :id => 100001,
        :resource_type => "003",
        :name => "更新対象ユーザグループ",
        :memo => "メモらしいにょ",
        :lock_version => "0"
      },
      :child_ids => ["999", "100004", "100007"]
    }
    
    logic = GroupLogic.new
    logic.save(params, ResourceType::USER_GROUP, 4989)
    
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0].parent_resource_id, 100001
    assert_equal actual_list[0].child_resource_id, 100001
    assert_equal actual_list[1].parent_resource_id, 100001
    assert_equal actual_list[1].child_resource_id, 100004
    
  end

  #
  # saveメソッド-更新のテスト
  # 設備グループ
  # 設備でないリソース、登録されていないリソースID指定
  #
  test "save3" do

    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100006, true)
    assert_equal actual_list.length, 2

    params = {
      :resource => {
        :id => 100006,
        :resource_type => "004",
        :name => "更新対象設備グループ",
        :memo => "メモーん",
        :lock_version => "0"
      },
      :child_ids => ["999", "100004", "100009"]
    }
    
    logic = GroupLogic.new
    logic.save(params, ResourceType::FACILITY_GROUP, 4989)
    
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100006, true)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0].parent_resource_id, 100006
    assert_equal actual_list[0].child_resource_id, 100009
    
  end

  #
  # saveメソッド-更新のテスト
  # リクエストパラメータが未設定
  #
  test "save4" do

    params = {
      :resource => {
        :id => 100001,
        :resource_type => "003",
        :name => "更新対象ユーザグループ",
        :memo => "メモらしいにょ",
        :lock_version => "0"
      },
      :child_ids => []
    }
    
    logic = GroupLogic.new
    begin
      logic.save(params, ResourceType::USER_GROUP, 4989)
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end
    
  end

  #
  # saveメソッド-更新のテスト
  # リクエストパラメータが設定されているが、該当データが1件も存在しない
  #
  test "save5" do

    params = {
      :resource => {
        :id => 100001,
        :resource_type => "003",
        :name => "更新対象ユーザグループ",
        :memo => "メモらしいにょ",
        :lock_version => "0"
      },
      :child_ids => ["123","999"]
    }
    
    logic = GroupLogic.new
    begin
      logic.save(params, ResourceType::USER_GROUP, 4989)
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end
  end

  #
  # get_resourceのテスト
  #
  test "get_resource" do
    logic = GroupLogic.new
    
    # ユーザグループで親を含む場合
    actual = logic.get_resource(100001, ResourceType::USER_GROUP, true)
    actual_resource = actual.resource
    actual_resource_conn_list = actual.resource_conn_list
    assert_equal actual_resource.id, 100001
    assert_equal actual_resource_conn_list.length, 4
    assert_equal actual_resource_conn_list[0].key, 100001
    assert_equal actual_resource_conn_list[0].value, "ユーザグループ1"
    assert_equal actual_resource_conn_list[1].key, 100002
    assert_equal actual_resource_conn_list[1].value, "ユーザA"
    assert_equal actual_resource_conn_list[2].key, 100003
    assert_equal actual_resource_conn_list[2].value, "ユーザB"
    assert_equal actual_resource_conn_list[3].key, 100004
    assert_equal actual_resource_conn_list[3].value, "ユーザC"
    
    # ユーザグループで親を含まない場合
    actual = logic.get_resource(100001, ResourceType::USER_GROUP, false)
    actual_resource = actual.resource
    actual_resource_conn_list = actual.resource_conn_list
    assert_equal actual_resource.id, 100001
    assert_equal actual_resource_conn_list.length, 3
    assert_equal actual_resource_conn_list[0].key, 100002
    assert_equal actual_resource_conn_list[0].value, "ユーザA"
    assert_equal actual_resource_conn_list[1].key, 100003
    assert_equal actual_resource_conn_list[1].value, "ユーザB"
    assert_equal actual_resource_conn_list[2].key, 100004
    assert_equal actual_resource_conn_list[2].value, "ユーザC"
    
  end

  #
  # get_resourceのテスト
  # 存在しない場合
  #
  test "get_resource2" do
    logic = GroupLogic.new
    begin
      logic.get_resource(123001, ResourceType::FACILITY_GROUP, false)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end    
  end

  #
  # deleteのテスト
  #
  test "delete" do
    logic = GroupLogic.new
    assert_not_nil logic.get_resource(100001, ResourceType::USER_GROUP, true)
    
    logic.delete("100001", ResourceType::USER_GROUP, "0")
    begin
      logic.get_resource(100001, ResourceType::USER_GROUP, true)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end    
    
  end

  test "get_group_resourcesのテスト" do
    
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 1
    pager_condition.per = 30
    logic = GroupLogic.new

    actual_list = logic.get_group_resources(100001, 900002, pager_condition)
    assert_equal actual_list.length, 4
    assert_equal actual_list[0], 100001
    assert_equal actual_list[1], 100002
    assert_equal actual_list[2], 100003
    assert_equal actual_list[3], 100004

    # ログインユーザの情報が、Listに含まれる
    actual_list = logic.get_group_resources(100001, 100003, pager_condition)
    assert_equal actual_list.length, 4
    assert_equal actual_list[0], 100003
    assert_equal actual_list[1], 100001
    assert_equal actual_list[2], 100002
    assert_equal actual_list[3], 100004

    # 該当データなし
    actual_list = logic.get_group_resources(999999, 100003, pager_condition)
    assert_equal actual_list.length, 0

    # ユーザを指定してしまった
    begin
      logic.get_group_resources(100003, 100003, pager_condition)
      assert_fail
    rescue CustomException::IllegalParameterException
      assert true
    end

    # ページャの確認
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 1
    pager_condition.per = 2

    actual_list = logic.get_group_resources(100001, 900002, pager_condition)
    assert_equal pager_condition.total_count.to_i, 4
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], 100001
    assert_equal actual_list[1], 100002

    # ページャの確認(表示するデータが無い)
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 5
    pager_condition.per = 10

    actual_list = logic.get_group_resources(100001, 900002, pager_condition)
    assert_equal pager_condition.total_count.to_i, 4
    assert_equal actual_list.length, 0
    
  end

  test "get_all_group_resourcesのテスト" do
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 1
    pager_condition.per = 30
    logic = GroupLogic.new

    # 全ユーザ
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_USERS, 
      900002, pager_condition)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], 100002
    assert_equal actual_list[1], 100003
    assert_equal actual_list[2], 100004

    # 全ユーザ(自分が含まれる)
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_USERS, 
      100004, pager_condition)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], 100004
    assert_equal actual_list[1], 100002
    assert_equal actual_list[2], 100003

    # 全設備
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_FACILITIES, 
      100004, pager_condition)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], 100007
    assert_equal actual_list[1], 100008
    assert_equal actual_list[2], 100009

    # 全ユーザグループ
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_USER_GROUP, 
      100004, pager_condition)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], 100001
    assert_equal actual_list[1], 100005

    # 固定値以外を指定してしまった
    begin
      logic.get_all_group_resources(100003, 100003, pager_condition)
      assert_fail
    rescue CustomException::IllegalParameterException
      assert true
    end
    
    # ページャの確認
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 1
    pager_condition.per = 2
    
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_USERS, 
      900002, pager_condition)
    assert_equal pager_condition.total_count.to_i, 3
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], 100002
    assert_equal actual_list[1], 100003

    # ページャの確認(対象ページに表示するデータが無い)
    pager_condition = SqlHelper::DefaultPagerCondition.new
    pager_condition.page = 10
    pager_condition.per = 10
    
    actual_list = logic.get_all_group_resources(FixGroupResourceIds::ALL_USERS, 
      900002, pager_condition)
    assert_equal pager_condition.total_count.to_i, 3
    assert_equal actual_list.length, 0
  end

end
