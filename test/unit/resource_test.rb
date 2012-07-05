# encoding: utf-8
require 'test_helper'

class ResourceTest < ActiveSupport::TestCase

  include SetupMethods
  # テスト前処理
  setup :create_resource
  
  # 条件による検索のテスト(ページング無し)
  test "find_by_conditions" do
    # 全件取得
    resource_search_param = ResourceSearchParam.new
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 7
    assert_equal actual_list[0], FactoryGirl.build(:resource1)
    assert_equal actual_list[1], FactoryGirl.build(:resource3)
    assert_equal actual_list[2], FactoryGirl.build(:resource2)
    assert_equal actual_list[3], FactoryGirl.build(:resource4)
    assert_equal actual_list[4], FactoryGirl.build(:resource5)
    assert_equal actual_list[5], FactoryGirl.build(:resource6)
    assert_equal actual_list[6], FactoryGirl.build(:resource7)
    
    # resource_type設定
    resource_search_param = ResourceSearchParam.new
    resource_search_param.resource_type = "MyS"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:resource1)
    assert_equal actual_list[1], FactoryGirl.build(:resource3)
    
    # name設定
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "MyString2"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:resource3)
    assert_equal actual_list[1], FactoryGirl.build(:resource2)

    # name設定(%を含むテスト)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "%"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource1)

    # name設定(％を含むテスト)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "％"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource4)

    # name設定(_を含むテスト)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "_"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource5)

    # name設定(＿を含むテスト)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "＿"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource6)

    # name設定(\を含むテスト)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.name = "\\"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource7)

    # id指定
    resource_search_param = ResourceSearchParam.new
    resource_search_param.ids = [100010, 100005, 100001, 100007]
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], FactoryGirl.build(:resource1)
    assert_equal actual_list[1], FactoryGirl.build(:resource5)
    assert_equal actual_list[2], FactoryGirl.build(:resource7)
  end

  # 条件による検索のテスト(検索条件無し、ページング有り)
  test "find_by_conditions_with_kaminari_no_param" do
    # 全件取得(ページ指定有り 1ページ目)
    resource_search_param = ResourceSearchParam.new
    resource_search_param.page = 1
    resource_search_param.per = 3
    
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 7
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], FactoryGirl.build(:resource1)
    assert_equal actual_list[1], FactoryGirl.build(:resource3)
    assert_equal actual_list[2], FactoryGirl.build(:resource2)

    # 全件取得(ページ指定有り 2ページ目)    
    resource_search_param = ResourceSearchParam.new
    resource_search_param.page = 2
    resource_search_param.per = 3
    
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 7
    assert_equal actual_list.length, 3
    assert_equal actual_list[0], FactoryGirl.build(:resource4)
    assert_equal actual_list[1], FactoryGirl.build(:resource5)
    assert_equal actual_list[2], FactoryGirl.build(:resource6)
    
    # 全件取得(ページ指定有り 3ページ目)    
    resource_search_param = ResourceSearchParam.new
    resource_search_param.page = 3
    resource_search_param.per = 3
    
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 7
    assert_equal actual_list.length, 1
    assert_equal actual_list[0], FactoryGirl.build(:resource7)

    # 全件取得(ページ指定有り 4ページ目、表示するレコード無し)    
    resource_search_param = ResourceSearchParam.new
    resource_search_param.page = 4
    resource_search_param.per = 3
    
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 7
    assert_equal actual_list.length, 0
    
  end

  # 条件による検索のテスト(検索条件有り、ページング有り)
  test "find_by_conditions_with_kaminari_param" do
    
    # id指定
    resource_search_param = ResourceSearchParam.new
    resource_search_param.ids = [100010, 100005, 100001, 100007]
    resource_search_param.page = 1
    resource_search_param.per = 2
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal resource_search_param.total_count, 3
    assert_equal actual_list.length, 2
    assert_equal actual_list[0], FactoryGirl.build(:resource1)
    assert_equal actual_list[1], FactoryGirl.build(:resource5)

  end

  
  # ソート順更新のテスト
  test "update_sort_num" do
    ids = [100006,100004,100005,100007]
    Resource.update_sort_num(ids, "hog")
    
    resource_search_param = ResourceSearchParam.new
    resource_search_param.resource_type = "hog"
    actual_list = Resource.find_by_conditions(resource_search_param)
    assert_equal actual_list.length, 4
    assert_equal actual_list[0].id, 100006
    assert_equal actual_list[0].sort_num, 1
    assert_equal actual_list[1].id, 100004
    assert_equal actual_list[1].sort_num, 2
    assert_equal actual_list[2].id, 100005
    assert_equal actual_list[2].sort_num, 3
    assert_equal actual_list[3].id, 100007
    assert_equal actual_list[3].sort_num, 4
    
  end
  
  # ソート順更新のテスト
  # idのフォーマットが英字
  test "update_sort_num_ng_illegal_ids" do
    ids = ["abc", 100006,100004,100005,100007]
    begin
      Resource.update_sort_num(ids, "hog")
      assert_fail
    rescue
      assert true
    end
  end
  
  
  # 登録時のvalidateテスト(正常)
  test "validate_ok" do
    
    resource = Resource.new
    resource[:resource_type] = ResourceType::USER
    resource[:name] = "name123"
    resource[:memo] = "memo123"
    resource[:sort_num] = MAX_LONG
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 15
    
    # validateエラーが無いこと
    assert !resource.invalid?

    # memoが空文字でも登録できること
    resource = Resource.new
    resource[:resource_type] = ResourceType::USER_GROUP
    resource[:name] = "name123"
    resource[:memo] = ""
    resource[:sort_num] = 33
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 15
    
    # validateエラーが無いこと
    assert !resource.invalid?

  end
  
  # リresource_typeのテスト
  test "validate_ng_resource_type" do

    # リソース区分がnil    
    resource = Resource.new
    resource[:resource_type] = nil
    resource[:name] = "name123"
    resource[:memo] = "memo123"
    resource[:sort_num] = MAX_LONG
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 15
    
    # 入力規制のチェック(DBアクセスはしない)
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:resource_type].any?
 
     # リソース区分が3文字より少ない
    resource = Resource.new
    resource[:resource_type] = "01"
    resource[:name] = "name123"
    resource[:memo] = "memo123"
    resource[:sort_num] = MAX_LONG
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 15
    
    # 入力規制のチェック
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:resource_type].any?

  end

  # nameのテスト
  test "validate_ng_name" do
    
    # nameが空文字
    resource = Resource.new
    resource[:resource_type] = "001"
    resource[:name] = ""
    resource[:memo] = "memo123"
    resource[:sort_num] = 15
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 0
    
    # 入力規制のチェック(DBアクセスはしない)
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:name].any?


    # nameがnil
    resource = Resource.new
    resource[:resource_type] = "001"
    resource[:name] = nil
    resource[:memo] = "memo123"
    resource[:sort_num] = 15
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 0
    
    # 入力規制のチェック(DBアクセスはしない)
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:name].any?

    # name文字数超(129文字)
    resource = Resource.new
    resource[:resource_type] = "001"
    resource[:name] = ""
    129.times do
      resource[:name] << "a"
    end
    resource[:memo] = ""
    1024.times do
      resource[:memo] << "a"
    end
    resource[:sort_num] = 15
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 0
    
    # 入力規制のチェック(DBアクセスはしない)
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:name].any?

  end


  # memoのテスト
  test "validate_ng_memo" do
    
    # memo文字数超(1025文字)
    resource = Resource.new
    resource[:resource_type] = "001"
    resource[:name] = ""
    128.times do
      resource[:name] << "a"
    end
    resource[:memo] = ""
    1025.times do
      resource[:memo] << "a"
    end
    resource[:sort_num] = 1
    resource[:entry_resource_id] = 123456
    resource[:update_resource_id] = 456789
    resource[:lock_version] = 0
    
    # 入力規制のチェック(DBアクセスはしない)
    assert resource.invalid?
    assert resource.errors.any?
    assert resource.errors[:memo].any?

  end
end
