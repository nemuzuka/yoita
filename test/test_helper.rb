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
    FactoryGirl.create(:user_info_resource1)
    FactoryGirl.create(:user_info_resource2)
    FactoryGirl.create(:user_info_resource3)
    FactoryGirl.create(:user_info_resource4)
    FactoryGirl.create(:user_info_resource5)
    FactoryGirl.create(:user_info_resource6)
    FactoryGirl.create(:user_info_resource7)
    FactoryGirl.create(:user_info_resource8)
    FactoryGirl.create(:user_info_resource9)
    FactoryGirl.create(:user_info1)
    FactoryGirl.create(:user_info2)
    FactoryGirl.create(:user_info3)
    FactoryGirl.create(:user_info4)
    FactoryGirl.create(:user_info5)
    FactoryGirl.create(:user_info6)
    FactoryGirl.create(:login1)
    FactoryGirl.create(:login2)
    FactoryGirl.create(:login3)
    FactoryGirl.create(:login4)
    FactoryGirl.create(:login5)
    FactoryGirl.create(:login6)
    
  end
  
  #
  # national_holidayテスト用
  #
  def create_national_holiday
    FactoryGirl.create(:national_holiday1)
    FactoryGirl.create(:national_holiday2)
    FactoryGirl.create(:national_holiday3)
    FactoryGirl.create(:national_holiday4)
    FactoryGirl.create(:national_holiday5)
    FactoryGirl.create(:national_holiday6)
    FactoryGirl.create(:national_holiday7)
    FactoryGirl.create(:national_holiday8)
    
  end
  
  #
  # scheduleテスト用
  #
  def create_schedule
    FactoryGirl.create(:schedule_model1)
    FactoryGirl.create(:schedule_conn_model1)
    FactoryGirl.create(:schedule_conn_model2)
    
  end
  
  #
  # ScheduleLogicテスト用
  #
  def create_schedule_logic
    create_user_facilities_group_conn
    FactoryGirl.create(:schedule1)
    FactoryGirl.create(:schedule2)
    FactoryGirl.create(:schedule3)
    FactoryGirl.create(:schedule4)
    FactoryGirl.create(:schedule5)
    FactoryGirl.create(:schedule6)
    FactoryGirl.create(:schedule7)
    FactoryGirl.create(:schedule8)
    FactoryGirl.create(:schedule9)
    FactoryGirl.create(:schedule10)
    FactoryGirl.create(:schedule11)
    FactoryGirl.create(:schedule12)
    FactoryGirl.create(:schedule13)
    FactoryGirl.create(:schedule14)
    FactoryGirl.create(:schedule_conn1)
    FactoryGirl.create(:schedule_conn2)
    FactoryGirl.create(:schedule_conn3)
    FactoryGirl.create(:schedule_conn4)
    FactoryGirl.create(:schedule_conn5)
    FactoryGirl.create(:schedule_conn6)
    FactoryGirl.create(:schedule_conn7)
    FactoryGirl.create(:schedule_conn8)
    FactoryGirl.create(:schedule_conn9)
    FactoryGirl.create(:schedule_conn10)
    FactoryGirl.create(:schedule_conn11)
    FactoryGirl.create(:schedule_conn12)
    FactoryGirl.create(:schedule_conn13)
    FactoryGirl.create(:schedule_conn14)
    FactoryGirl.create(:schedule_conn15)
    FactoryGirl.create(:schedule_conn16)
    
  end

  #
  # ScheduleFollowLogicテスト用
  #
  def create_schedule_follow_logic
    create_schedule_logic
    FactoryGirl.create(:schedule_follow1)
    FactoryGirl.create(:schedule_follow2)
    FactoryGirl.create(:schedule_follow3)
    FactoryGirl.create(:schedule_follow4)
    FactoryGirl.create(:schedule_follow5)
    FactoryGirl.create(:schedule_follow6)
    FactoryGirl.create(:schedule_follow7)
    FactoryGirl.create(:schedule_follow8)
  end
  
end
