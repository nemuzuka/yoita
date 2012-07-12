# encoding: utf-8
require 'test_helper'

# ResourceLogicのテストクラス
class ResourceLogicTest < ActiveSupport::TestCase
  
  include SetupMethods
  # テスト前処理
  setup :create_resource
  
  #
  # saveメソッド-追加のテスト
  #
  test "save_create" do
    params = {
      :resource => {
        :id => "",
        :name => "ほげほげ",
        :memo => "メモらしい",
        :lock_version => ""
      }
    }
    
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, ResourceType::USER, 1234)
    
    store_target = Resource.find_by_id(resource[:id])
    assert_equal resource, store_target
  end

  #
  # validateエラーの場合の処理
  # 名称空文字
  #
  test "save_create_ng_validate_error" do
    params = {
      :resource => {
        :id => "",
        :name => "",
        :memo => "",
        :lock_version => ""
      }
    }
    
    resource_logic = ResourceLogic.new
    begin
      resource_logic.save(params, ResourceType::USER, 1234)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end
  end


  #
  # validateエラーの場合の処理
  # 名称空文字、memo最大値超
  #
  test "save_create_ng_2validates_error" do
    params = {
      :resource => {
        :id => "",
        :name => "",
        :memo => "",
        :lock_version => ""
      }
    }
    
    1025.times do
      params[:resource][:memo] << "a"
    end
    
    resource_logic = ResourceLogic.new
    begin
      resource_logic.save(params, ResourceType::USER, 1234)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 2
    end
  end

  #
  # saveメソッド-更新のテスト
  #
  test "save_update" do
    params = {
      :resource => {
        :id => 100001,
        :resource_type => "Rai",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :sort_num => 4989,
        :entry_resource_id => 1600,
        :update_resource_id => 1603,
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, "MyS", 1234)
    
    store_target = Resource.find_by_id(resource[:id])
    assert_equal resource[:id], 100001
    assert_equal resource[:name], "ほげほぎゃ"
    assert_equal resource[:memo], "メモらしいにょ"
    assert_equal resource[:sort_num], 1
    assert_equal resource[:entry_resource_id], 1
    assert_equal resource[:update_resource_id], 1234
    assert_equal resource[:lock_version], 2
    
  end

  #
  # saveメソッド-更新のテスト
  # 更新前と後で内容が同じでも、update文を発行してlock_versionを変更させる
  #
  test "save_update_no_update_column" do
    params = {
      :resource => {
        :id => 100001,
        :name => "MyS%tring1",
        :memo => "memo1",
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    resource = resource_logic.save(params, "MyS", 1234)
    
    store_target = Resource.find_by_id(resource[:id])
    assert_equal resource[:id], 100001
    assert_equal resource[:name], "MyS%tring1"
    assert_equal resource[:memo], "memo1"
    assert_equal resource[:sort_num], 1
    assert_equal resource[:entry_resource_id], 1
    assert_equal resource[:update_resource_id], 1234
    assert_equal resource[:lock_version], 2
    
  end


  #
  # saveメソッド-更新のテスト
  # 該当id存在無し
  #
  test "save_update_ng_not_found_id" do
    params = {
      :resource => {
        :id => "9999",
        :resource_type => "Rai",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :sort_num => 4989,
        :entry_resource_id => 1600,
        :update_resource_id => 1603,
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # リソース区分がDBの値と異なる
  #
  test "save_update_ng_illegal_resource_type" do
    params = {
      :resource => {
        :id => "100001",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "002", 1234)
      assert_fail
    rescue CustomException::IllegalParameterException => e
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # バージョンNoが期待値でない
  #
  test "save_update_ng_illegal_lock_version" do
    params = {
      :resource => {
        :id => "100001",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :lock_version => "123"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::InvalidVersionException => e
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # バージョンNoが英字である
  #
  test "save_update_ng_illegal_lock_version_format" do
    params = {
      :resource => {
        :id => "100001",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :lock_version => "abc"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::InvalidVersionException => e
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # バージョンNoがnilである
  #
  test "save_update_ng_illegal_lock_version_nil" do
    params = {
      :resource => {
        :id => "100001",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :lock_version => nil
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::InvalidVersionException => e
      assert true
    end
  end


  #
  # saveメソッド-更新のテスト
  # idが英字である
  # 該当レコード無しエラーになる模様
  #
  test "save_update_ng_illegal_id_format" do
    params = {
      :resource => {
        :id => "abc",
        :name => "ほげほぎゃ",
        :memo => "メモらしいにょ",
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::NotFoundException => e
      assert true
    end
  end

  #
  # saveメソッド-更新のテスト
  # validateエラー
  #
  test "save_update_ng_validate_error" do
    params = {
      :resource => {
        :id => "100001",
        :name => "",
        :memo => "メモらしいにょ",
        :lock_version => "1"
      }
    }
    
    resource_logic = ResourceLogic.new
    
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 1
    end
    
  end

  #
  # saveメソッド-更新のテスト
  # validateエラーの場合の処理
  # 名称空文字、memo最大値超
  #
  test "save_update_ng_2validates_error" do
    params = {
      :resource => {
        :id => "100001",
        :name => "",
        :memo => "",
        :lock_version => "1"
      }
    }
    
    1025.times do
      params[:resource][:memo] << "a"
    end
    
    resource_logic = ResourceLogic.new
    begin
      resource_logic.save(params, "MyS", 1234)
      assert_fail
    rescue CustomException::ValidationException => e
      assert_equal e.msgs.length, 2
    end
  end

  #
  # deleteのテスト
  #
  test "delete" do
    assert_not_nil Resource.find_by_id(100001)
    
    resource_logic = ResourceLogic.new
    resource_logic.delete(100001, "MyS", 1)
    
    assert_nil Resource.find_by_id(100001)
  end

  #
  # deleteのテスト
  # バージョンが異なる
  #
  test "delete_ng_illegal_lock_version" do
    assert_not_nil Resource.find_by_id(100001)
    
    resource_logic = ResourceLogic.new
    begin
      resource_logic.delete(100001, "MyS", 9)
      assert_fail
    rescue CustomException::InvalidVersionException => e
      assert true
    end

    assert_not_nil Resource.find_by_id(100001)
  end

  #
  # deleteのテスト
  # バージョンが数値でない
  #
  test "delete_ng_illegal_lock_version_format" do
    assert_not_nil Resource.find_by_id(100001)
    
    resource_logic = ResourceLogic.new
    begin
      resource_logic.delete(100001, "MyS", "abc")
      assert_fail
    rescue CustomException::InvalidVersionException => e
      assert true
    end

    assert_not_nil Resource.find_by_id(100001)
  end

end
