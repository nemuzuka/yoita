# encoding: utf-8
require 'test_helper'
require "constants"
require 'digest/sha2'

# UserInfoLogicのテストクラス
class UserInfoLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_user_info
  
  #
  # saveメソッド-登録のテスト
  #
  test "save" do

    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31"
      },
      :login => {
        :login_id => "hoge1",
        :password => "hogehogehogeABC"
      }
    }
    
    logic = UserInfoLogic.new
    resource = logic.save(params, ResourceType::USER, 4989)
    
    actual_user_info = UserInfo.find_by_resource_id(resource.id)
    assert_equal actual_user_info[:reading_character], "ゆーざA"
    assert_equal actual_user_info[:tel], "123-4567-8901"
    assert_equal actual_user_info[:mail], "hoge@hige.hage"
    assert_equal actual_user_info[:admin_flg], "1"
    assert_equal actual_user_info[:per_page], 10
    assert_equal actual_user_info[:validity_start_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_user_info[:validity_end_date], Date.strptime("2010/12/31", "%Y/%m/%d")
    
    actual_login = Login.find_by_resource_id(resource.id)
    assert_equal actual_login[:login_id], "hoge1"
    assert_equal actual_login[:password], Digest::SHA512.hexdigest("hogehogehogeABC")

    # 有効終了日が未設定の場合、最大日付を設定
    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_start_date => "2010/01/01",
        :validity_end_date => ""
      },
      :login => {
        :login_id => "hoge2",
        :password => "hogehogehoge123"
      }
    }
    
    logic = UserInfoLogic.new
    resource = logic.save(params, ResourceType::USER, 4989)
    
    actual_user_info = UserInfo.find_by_resource_id(resource.id)
    assert_equal actual_user_info[:validity_start_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_user_info[:validity_end_date], Date.strptime("2999/12/31", "%Y/%m/%d")
    
    # 認証のテスト
    assert_not_nil logic.auth("hoge2", "hogehogehoge123")
    assert_nil logic.auth("hoge2", "hogehogehoge124")
    assert_nil logic.auth("kkaz", "hogehogehoge123")
  end

  #
  # saveメソッド-共通validateのテスト
  #
  test "save-validate-ng" do
    # 有効開始日が未設定
    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_end_date => "2010/12/31"
      },
      :login => {
        :login_id => "hoge1",
        :password => "hogehogehoge123"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end

    # 有効開始日>有効終了日の関係
    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_start_date => "2010/01/02",
        :validity_end_date => "2010/01/01"
      },
      :login => {
        :login_id => "hoge1",
        :password => "hogehogehoge123"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end

    # パスワード必須
    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/01/03"
      },
      :login => {
        :login_id => "hoge1",
        :password => ""
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end

    # パスワード6文字未満
    params = {
      :resource => {
        :name => "ユーザA",
        :memo => "メモリん",
        :lock_version => ""
      },
      :user_info => {
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "hoge@hige.hage",
        :admin_flg => "1",
        :per_page => "10",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/01/03"
      },
      :login => {
        :login_id => "hoge1",
        :password => "12345"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end

  end

  #
  # saveメソッド-更新のテスト
  #
  test "save-update" do

    # パスワード更新有り
    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "11"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :password => "hogehogehogeABC",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "21"
      }
    }
    
    logic = UserInfoLogic.new
    resource = logic.save(params, ResourceType::USER, 4989)
    
    actual_user_info = UserInfo.find_by_resource_id(resource.id)
    assert_equal actual_user_info[:resource_id], 100001
    assert_equal actual_user_info[:reading_character], "ゆーざA"
    assert_equal actual_user_info[:tel], "123-4567-8901"
    assert_equal actual_user_info[:mail], "change_hige@hoge.hage"
    assert_equal actual_user_info[:admin_flg], "0"
    assert_equal actual_user_info[:per_page], 10
    assert_equal actual_user_info[:default_user_group], nil
    assert_equal actual_user_info[:validity_start_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_user_info[:validity_end_date], Date.strptime("2010/12/31", "%Y/%m/%d")
    assert_equal actual_user_info[:entry_resource_id], 1234
    assert_equal actual_user_info[:update_resource_id], 4989
    assert_equal actual_user_info[:lock_version], 12
    
    actual_login = Login.find_by_resource_id(resource.id)
    assert_equal actual_login[:resource_id], 100001
    assert_equal actual_login[:login_id], "hohohoge1"
    assert_equal actual_login[:password], Digest::SHA512.hexdigest("hogehogehogeABC")
    assert_equal actual_login[:entry_resource_id], 3335
    assert_equal actual_login[:update_resource_id], 4989
    assert_equal actual_login[:lock_version], 22

  end

  #
  # saveメソッド-更新のテスト
  # パスワード更新無し
  #
  test "save-update2" do

    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "11"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "999"
      }
    }
    
    logic = UserInfoLogic.new
    resource = logic.save(params, ResourceType::USER, 4989)
    
    actual_user_info = UserInfo.find_by_resource_id(resource.id)
    assert_equal actual_user_info[:resource_id], 100001
    assert_equal actual_user_info[:reading_character], "ゆーざA"
    assert_equal actual_user_info[:tel], "123-4567-8901"
    assert_equal actual_user_info[:mail], "change_hige@hoge.hage"
    assert_equal actual_user_info[:admin_flg], "0"
    assert_equal actual_user_info[:per_page], 10
    assert_equal actual_user_info[:default_user_group], nil
    assert_equal actual_user_info[:validity_start_date], Date.strptime("2010/01/01", "%Y/%m/%d")
    assert_equal actual_user_info[:validity_end_date], Date.strptime("2010/12/31", "%Y/%m/%d")
    assert_equal actual_user_info[:entry_resource_id], 1234
    assert_equal actual_user_info[:update_resource_id], 4989
    assert_equal actual_user_info[:lock_version], 12
    
    # loginは更新されていないこと
    actual_login = Login.find_by_resource_id(resource.id)
    assert_equal actual_login[:resource_id], 100001
    assert_equal actual_login[:login_id], "hohohoge1"
    assert_equal actual_login[:password], "意味なしパスワード"
    assert_equal actual_login[:entry_resource_id], 3335
    assert_equal actual_login[:update_resource_id], 45678
    assert_equal actual_login[:lock_version], 21

  end


  #
  # saveメソッド-更新のテスト
  # バージョン違い
  #
  test "save-update-ng" do

    # user_infoのバージョン違い
    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "10"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :password => "hogehogehogeABC",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "21"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::InvalidVersionException
      assert true
    end

    # パスワード設定時のバージョン違い
    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "11"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :password => "hogehogehogeABC",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "20"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::InvalidVersionException
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # validateエラー
  # パスワード長が短い
  #
  test "save-update-ng2" do

    # パスワード長が短い
    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "",
        :validity_start_date => "2010/01/01",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "10"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :password => "short",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "21"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # validateエラー
  # user_info更新時のエラー
  #
  test "save-update-ng3" do

    params = {
      :resource => {
        :id => 100001,
        :name => "変更後ユーザA",
        :memo => "変更後メモリん",
        :lock_version => "1"
      },
      :user_info => {
        :resource_id => 101,
        :reading_character => "ゆーざA",
        :tel => "123-4567-8901",
        :mail => "change_hige@hoge.hage",
        :admin_flg => "0",
        :per_page => "10",
        :default_user_group => "1234",
        :validity_start_date => "",
        :validity_end_date => "2010/12/31",
        :entry_resource_id => 9999999,
        :update_resource_id => 9999998,
        :lock_version => "10"
      },
      :login => {
        :resource_id => 102,
        :login_id => "hohohoho1",
        :password => "123456",
        :entry_resource_id => 9999997,
        :update_resource_id => 9999996,
        :lock_version => "21"
      }
    }
    
    logic = UserInfoLogic.new
    begin
      logic.save(params, ResourceType::USER, 4989)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
      assert true
    end
  end

  #
  # get_detailのテスト
  #
  test "get_detail" do
    logic = UserInfoLogic.new
    actual = logic.get_detail("100002")
    resource = actual.resource
    assert_not_nil resource
    
    user_info = actual.user_info
    assert_equal user_info[:resource_id], 100002
    assert_equal user_info[:reading_character], "ユーザBのふりがな"
    assert_equal user_info[:tel], "234-567-8901"
    assert_equal user_info[:mail], "hige2@hoge.hage"
    assert_equal user_info[:admin_flg], "0"
    assert_equal user_info[:per_page], 10
    assert_equal user_info[:default_user_group], 1
    assert_equal user_info[:validity_start_date], Date.strptime("2012/07/01", "%Y/%m/%d")
    assert_equal user_info[:validity_end_date], Date.strptime("2012/07/31", "%Y/%m/%d")
    assert_equal user_info[:entry_resource_id], 9012
    assert_equal user_info[:update_resource_id], 1123
    assert_equal user_info[:lock_version], 12
    
    login = actual.login
    assert_equal login[:resource_id], 100002
    assert_equal login[:login_id], "hohohoge2"
    assert_equal login[:password], "意味なしパスワード2"
    assert_equal login[:entry_resource_id], 87654
    assert_equal login[:update_resource_id], 12345678
    assert_equal login[:lock_version], 22
    
    # 該当レコード無し
    begin
      logic.get_detail(1)
      assert_fail
    rescue CustomException::NotFoundException
      assert true
    end
  end

  #
  # deleteのテスト
  #
  test "delete" do
    params = {
      :resource => {
        :id => 100001,
        :lock_version => "1"
      },
      :user_info => {
        :lock_version => "11"
      },
      :login => {
        :lock_version => "21"
      }
    }
    logic = UserInfoLogic.new
    logic.delete(params)
    
    begin
      logic.get_detail(100001)
      assert_fail
    rescue CustomException::NotFoundException
      assert true
    end

  end

end
