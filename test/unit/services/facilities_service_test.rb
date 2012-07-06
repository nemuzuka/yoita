# encoding: utf-8
require 'test_helper'

# FacilitiesServiceのテストクラス
class FacilitiesServiceTest < ActiveSupport::TestCase
  
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
    
    facilities_service = FacilitiesService.new
    resource = facilities_service.save(params, 4989)
    
    store_target = Resource.find_by_id(resource[:id])
    assert_equal resource, store_target

  end

  #
  # saveメソッド-validateエラーでロールバックのテスト
  #
  test "save_rollback" do
    resources = Resource.find(:all)
    assert_equal resources.length, 7
    
    params = {
      :resource => {
        :id => "",
        :name => "",
        :memo => "",
        :lock_version => ""
      }
    }

    facilities_service = FacilitiesService.new
    begin
      resource = facilities_service.save(params, 4989)
      assert_fail
    rescue 
      assert true
    end
    
    # 件数が増えていないこと
    resources = Resource.find(:all)
    assert_equal resources.length, 7
  end

end
