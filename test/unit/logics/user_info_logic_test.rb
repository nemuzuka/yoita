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
    assert_not_nil Login.auth("hoge2", "hogehogehoge123")
    assert_nil Login.auth("hoge2", "hogehogehoge124")
    assert_nil Login.auth("hoge3", "hogehogehoge123")
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

end
