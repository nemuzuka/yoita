# encoding: utf-8
require 'test_helper'
require 'digest/sha2'

class LoginTest < ActiveSupport::TestCase
  #
  # validateのテスト
  #
  test "validate_ok" do
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = "hogehoge"
    login[:password] = Digest::SHA512.hexdigest("password")
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが無いこと
    assert !login.invalid?

    # 最大桁数チェック
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = ""
    256.times do
      login[:login_id] << 'a'
    end
    login[:password] = ""
    256.times do
      login[:password] << 'p'
    end
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが無いこと
    assert !login.invalid?

  end
  
  #
  # login_idの文字列長エラー
  #
  test "validate_ng_01" do
    # 必須チェック
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = ""
    login[:password] = "hogehoge"
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert login.invalid?
    assert login.errors.any?
    assert login.errors[:login_id].any?
    
    # 最大桁数チェック
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = ""
    257.times do
      login[:login_id] << 'a'
    end
    login[:password] = "hogehoge"
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert login.invalid?
    assert login.errors.any?
    assert login.errors[:login_id].any?
    
  end
  
  #
  # passwordの文字列長エラー
  #
  test "validate_ng_02" do
    # 必須チェック
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = "hogehoge"
    login[:password] = ""
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert login.invalid?
    assert login.errors.any?
    assert login.errors[:password].any?
    
    # 最大桁数チェック
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = "hogehoge"
    login[:password] = ""
    257.times do
      login[:login_id] << 'a'
    end
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    
    # validateエラーが存在すること
    assert login.invalid?
    assert login.errors.any?
    assert login.errors[:password].any?
    
  end

  #
  # 一意制約エラーの確認
  #
  test "UniqueConstraint" do
    login = Login.new
    login[:resource_id] = 123456
    login[:login_id] = "hogehoge"
    login[:password] = Digest::SHA512.hexdigest("password")
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    login.save!

    login = Login.new
    login[:resource_id] = 123457
    login[:login_id] = "hogehoge"
    login[:password] = Digest::SHA512.hexdigest("password2")
    login[:entry_resource_id] = 1002
    login[:update_resource_id] = 1002
    begin
      login.save!
      assert_fail
    rescue ActiveRecord::RecordNotUnique
      assert true
    end
  end
end
