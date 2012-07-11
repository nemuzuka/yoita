require 'test_helper'

class UserFacilitiesGroupConnTest < ActiveSupport::TestCase

  include SetupMethods
  # テスト前処理
  setup :create_user_facilities_group_conn
  
  #
  # find_by_parent_idのテスト
  #
  test "find_by_parent_id" do
    # 親も含める(ユーザグループ)
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 4
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn1)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn2)
    assert_equal actual_list[2], FactoryGirl.build(:user_facilities_group_conn3)
    assert_equal actual_list[3], FactoryGirl.build(:user_facilities_group_conn4)

    # 親は含めない(ユーザグループ)
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, false)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn2)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn3)
    assert_equal actual_list[2], FactoryGirl.build(:user_facilities_group_conn4)

    # 親も含める(設備グループ) →実際にはありえない
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100006, true)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn8)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn9)

    # 親は含めない(設備グループ)
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100006, false)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn8)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn9)
    
  end

  # 
  # delete_by_parent_idのテスト
  #
  test "delete_by_parent_id" do
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9
    
    UserFacilitiesGroupConn.delete_by_parent_id(100006)
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100006, false)
    assert_equal actual_list.length, 0

    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 7

  end

  # 
  # delete_by_parent_idのテスト
  # 存在しないレコードを削除してもエラーにならない
  #
  test "delete_by_parent_id2" do
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9
    
    UserFacilitiesGroupConn.delete_by_parent_id(900006)

    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9

  end

  # 
  # delete_by_child_idのテスト
  #
  test "delete_by_child_id" do
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9
    
    UserFacilitiesGroupConn.delete_by_child_id(100002)
    
    # グループ関連データからも削除されていること
    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100001, true)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn1)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn3)
    assert_equal actual_list[2], FactoryGirl.build(:user_facilities_group_conn4)

    actual_list = UserFacilitiesGroupConn.find_by_parent_id(100005, true)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:user_facilities_group_conn5)
    assert_equal actual_list[1], FactoryGirl.build(:user_facilities_group_conn7)


    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 7

  end

  # 
  # delete_by_child_idのテスト
  # 存在しないレコードを削除してもエラーにならない
  #
  test "delete_by_child_id2" do
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9
    
    UserFacilitiesGroupConn.delete_by_child_id(900002)
    
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9

  end

  #
  # insert_child_listのテスト
  #
  test "insert_child_list" do
    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 9

    ids = ["1192","100002", "100004"]
    UserFacilitiesGroupConn.insert_child_list("1192", ids)

    actual_list = UserFacilitiesGroupConn.find_by_parent_id(1192, true)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0].child_resource_id, 1192
    assert_equal actual_list[1].child_resource_id, 100002
    assert_equal actual_list[2].child_resource_id, 100004

    total_list = UserFacilitiesGroupConn.find(:all)
    assert_equal total_list.length, 12

  end

end
