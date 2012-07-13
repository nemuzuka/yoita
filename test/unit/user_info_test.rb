# encoding: utf-8
require 'test_helper'

class UserInfoTest < ActiveSupport::TestCase

  include SetupMethods
  # テスト前処理
  setup :create_user_info
  
  #
  # validateのテスト
  #
  test "validate_ok" do
    
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりがな"
    user_info[:tel] = "0258-11-2345"
    user_info[:mail] = "hoge@hige.hage"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが無いこと
    assert !user_info.invalid?

    # 各項目の最大桁数チェック
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = ""
    128.times do
      user_info[:reading_character] << "a"
    end
    user_info[:tel] = ""
    48.times do
      user_info[:tel] << "b"
    end
    user_info[:mail] = ""
    256.times do
      user_info[:mail] << "c"
    end
    user_info[:admin_flg] = "1"
    user_info[:per_page] = 999
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    # validateエラーが無いこと
    assert !user_info.invalid?

  end
  
  #
  # ふりがなの文字列長エラー
  #
  test "validate_ng_01" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = ""
    129.times do
      user_info[:reading_character] << "a"
    end
    user_info[:tel] = "0123-456-7890"
    user_info[:mail] = "hoge@hige.hage"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:reading_character].any?
  end

  #
  # 電話番号の文字列長エラー
  #
  test "validate_ng_02" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = ""
    49.times do
      user_info[:tel] << "b"
    end
    user_info[:mail] = "hoge@hige.hage"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:tel].any?
  end

  #
  # mailの文字列長エラー
  #
  test "validate_ng_03" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = ""
    257.times do
      user_info[:mail] << "c"
    end
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:mail].any?
  end

  #
  # 管理者権限フラグが不正
  #
  test "validate_ng_04" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "2"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:admin_flg].any?

    # 1文字でない
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "00"
    user_info[:per_page] = 15
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:admin_flg].any?

  end

  #
  # 表示件数が不正
  #
  test "validate_ng_05" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = "a"
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:per_page].any?

    # 1より小さい
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "1"
    user_info[:per_page] = 0
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:per_page].any?

    # 999より大きい
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 1000
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = "20010101"
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:per_page].any?

  end

  #
  # 有効開始日が不正
  #
  test "validate_ng_06" do
    user_info = UserInfo.new
    user_info[:resource_id] = 123456
    user_info[:reading_character] = "ふりふり"
    user_info[:tel] = "000-111-2222"
    user_info[:mail] = "hage@hige.hoge"
    user_info[:admin_flg] = "0"
    user_info[:per_page] = 50
    user_info[:default_user_group] = 10001
    user_info[:validity_start_date] = ""
    user_info[:validity_end_date] = "2012/12/31"
    user_info[:entry_resource_id] = 1002
    user_info[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert user_info.invalid?
    assert user_info.errors.any?
    assert user_info.errors[:validity_start_date].any?
  end

  #
  # find_by_conditionsのテスト
  #
  test "find_by_conditions" do
    # 基準日時点で有効なレコード全て
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 4
    assert_equal actual_list[0][:resource_id], 100003
    assert_equal actual_list[0][:name], "検索用ユーザ1-1"
    assert_equal actual_list[0][:memo], "memo1-1"
    assert_equal actual_list[0][:resource_lock_version], "10001"
    assert_equal actual_list[0][:reading_character], "ゆーざ1-1"
    assert_equal actual_list[0][:tel], "tel-001"
    assert_equal actual_list[0][:mail], "user1-1@mail.com"
    assert_equal actual_list[0][:admin_flg], "0"
    assert_equal actual_list[0][:validity_start_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_list[0][:validity_end_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_list[0][:user_info_lock_version], "201"
    assert_equal actual_list[0][:login_id], "user1-1"
    assert_equal actual_list[0][:login_lock_version], "301"
    assert_equal actual_list[1][:resource_id], 100004
    assert_equal actual_list[2][:resource_id], 100006
    assert_equal actual_list[3][:resource_id], 100005

    # 基準日時点で有効なレコード全て
    # 検索条件：名称
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    param.name = "用ユーザ3"
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 2
    assert_equal actual_list[0][:resource_id], 100006
    assert_equal actual_list[1][:resource_id], 100005

    # 基準日時点で有効なレコード全て
    # 検索条件：ふりがな
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    param.reading_character = "ゆーざ3"
    param.admin_only = false
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 2
    assert_equal actual_list[0][:resource_id], 100006
    assert_equal actual_list[1][:resource_id], 100005

    # 基準日時点で有効なレコード全て
    # 検索条件：管理者のみ
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    param.admin_only = true
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 2
    assert_equal actual_list[0][:resource_id], 100004
    assert_equal actual_list[1][:resource_id], 100006

    # 基準日時点で有効なレコード全て
    # 検索条件：リソースID指定
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    param.resource_id = 100005
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 1
    assert_equal actual_list[0][:resource_id], 100005

    # 基準日時点で有効なレコード全て
    # 検索条件：リソースIDList指定
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/01", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    param.resource_id_list = ["100008", "100004", "100002", "100005", "100006", "100009"]
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 3
    assert_equal actual_list[0][:resource_id], 100004
    assert_equal actual_list[1][:resource_id], 100006
    assert_equal actual_list[2][:resource_id], 100005

    # 基準日時点で有効なレコード全て
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::EXCLUDE_DISABLE_DATA
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 1
    assert_equal actual_list[0][:resource_id], 100006

    # 基準日時点で無効なレコードのみ
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::ONLY_DISABLE_DATA
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 5
    assert_equal actual_list[0][:resource_id], 100001
    assert_equal actual_list[1][:resource_id], 100002
    assert_equal actual_list[2][:resource_id], 100003
    assert_equal actual_list[3][:resource_id], 100004
    assert_equal actual_list[4][:resource_id], 100005
    
    # 全ての検索条件を付与しても、エラーにならないこと
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::ONLY_DISABLE_DATA
    param.name = "a"    
    param.reading_character = "b"
    param.admin_only = true
    param.resource_id = 101
    param.resource_id_list = [10,12,987,3]
    # 正常に発行できていれば良い
    actual_list = UserInfo.find_by_conditions(param)
  end

  #
  # find_by_conditionsのテスト
  #
  test "find_by_conditions2" do
    # 基準日時点で無効なレコードのみ
    # 1ページ目
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::ONLY_DISABLE_DATA
    param.per = 3
    param.page = 1
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 5
    assert_equal actual_list.length, 3
    assert_equal actual_list[0][:resource_id], 100001
    assert_equal actual_list[1][:resource_id], 100002
    assert_equal actual_list[2][:resource_id], 100003

    # 基準日時点で無効なレコードのみ
    # 2ページ目
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::ONLY_DISABLE_DATA
    param.per = 3
    param.page = 2
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 5
    assert_equal actual_list.length, 2
    assert_equal actual_list[0][:resource_id], 100004
    assert_equal actual_list[1][:resource_id], 100005

    # 基準日時点で無効なレコードのみ
    # 3ページ目
    param = UserInfo::SearchParam.new
    param.search_base_date = Date.strptime("2010/01/03", "%Y/%m/%d") 
    param.search_type = SearchType::ONLY_DISABLE_DATA
    param.per = 3
    param.page = 3
    actual_list = UserInfo.find_by_conditions(param)
    assert_equal param.total_count.to_i, 5
    assert_equal actual_list.length, 0
    
  end


end
