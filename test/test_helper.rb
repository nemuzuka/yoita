ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


# Unitテストのセットアップ用モジュール群
module SetupMethods
  
  #
  # resourceテスト用
  #
  def create_resource
    FactoryGirl.create(:resource1)
    FactoryGirl.create(:resource2)
    FactoryGirl.create(:resource3)
    FactoryGirl.create(:resource4)
    FactoryGirl.create(:resource5)
    FactoryGirl.create(:resource6)
    FactoryGirl.create(:resource7)
  end
  
  #
  # user_facilities_group_connテスト用
  #
  def create_user_facilities_group_conn
    FactoryGirl.create(:user_facilities_group_conn_resource1)
    FactoryGirl.create(:user_facilities_group_conn_resource2)
    FactoryGirl.create(:user_facilities_group_conn_resource3)
    FactoryGirl.create(:user_facilities_group_conn_resource4)
    FactoryGirl.create(:user_facilities_group_conn_resource5)
    FactoryGirl.create(:user_facilities_group_conn_resource6)
    FactoryGirl.create(:user_facilities_group_conn_resource7)
    FactoryGirl.create(:user_facilities_group_conn_resource8)
    FactoryGirl.create(:user_facilities_group_conn_resource9)
    FactoryGirl.create(:user_facilities_group_conn1)
    FactoryGirl.create(:user_facilities_group_conn2)
    FactoryGirl.create(:user_facilities_group_conn3)
    FactoryGirl.create(:user_facilities_group_conn4)
    FactoryGirl.create(:user_facilities_group_conn5)
    FactoryGirl.create(:user_facilities_group_conn6)
    FactoryGirl.create(:user_facilities_group_conn7)
    FactoryGirl.create(:user_facilities_group_conn8)
    FactoryGirl.create(:user_facilities_group_conn9)
  end
  
  #
  # user_infoテスト用
  #
  def create_user_info
    
  end
  
end
