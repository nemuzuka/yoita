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

end
