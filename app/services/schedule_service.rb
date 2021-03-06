# encoding: utf-8
require "constants"
require "service"
require "model"

#
# スケジュールに対するService
#
class ScheduleService < Service::Base
  
  #
  # スケジュール登録・更新
  # スケジュール情報を登録・更新した後、関連データを登録します
  # ==== _Args_
  # [params]
  #   スケジュール登録・更新情報
  # [action_resource_id]
  #   登録・更新処理実行ユーザリソースID
  # ==== _Return_
  # 処理スケジュール
  # see. <i>Schedule</i>
  #
  def save(params, action_resource_id)
    transaction_handler do
      logic = ScheduleLogic.new
      logic.save(params, action_resource_id)
    end
  end

  #
  # スケジュール削除
  # ==== _Args_
  # [schedule_id]
  #   スケジュールID
  # [lock_version]
  #   バージョンNo
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  # [CustomException::InvalidVersionException]
  #   バージョンが合わない場合
  #
  def delete(schedule_id, lock_version, action_resource_id)
    transaction_handler do
      logic = ScheduleLogic.new
      logic.delete(schedule_id, lock_version, action_resource_id)
    end
  end

  
  #
  # リソース指定週次スケジュール表示データ作成
  # 指定期間に対する、指定リソースの週次スケジュール表示データを作成します
  # ==== _Args_
  # [target_date]
  #   表示対象日付
  # [target_resource_id]
  #   表示対象リソースID
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleService::ScheduleView</i>)
  #
  def create_resource_schedule_view_week(target_date, target_resource_id, action_resource_id)
    transaction_handler do
      # 基準日から1週間分の日付Listを取得
      target_dates = DateHelper::create_date_list(target_date, 7)
      schedule_view = create_resources_schedule_view(target_dates, [target_resource_id], action_resource_id)
      schedule_view.target_group_resource_id = ""
      return schedule_view
    end
  end

  #
  # グループ指定週次スケジュール表示データ作成
  # 指定期間に対する、指定グループの週次スケジュール表示データを作成します
  # ==== _Args_
  # [target_date]
  #   表示対象日付
  # [search_param]
  #   検索条件。(see. <i>ScheduleService::SearchParam</i>)
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleService::ScheduleView</i>)
  #
  def create_group_schedule_view_week(target_date, search_param, action_resource_id)
    transaction_handler do
      target_resource_id = search_param.group_resource_id.to_i
      group_logic = GroupLogic.new
      resource_ids = []
      if target_resource_id < 0 
        # 固定グループに紐付くリソースID
        resource_ids = group_logic.get_fix_group_resources(
          target_resource_id, action_resource_id, search_param)
      else
        # 指定グループに紐付くリソースID
        resource_ids = group_logic.get_group_resources(
          target_resource_id, action_resource_id, search_param)
  
        # 該当リソースIDが1件も存在しない場合、無効なグループを指定されたとみなし、
        # 全てのユーザのデータを取得し直す
        if search_param.total_count.to_i == 0
          search_param.group_resource_id = FixGroupResourceIds::ALL_USERS.to_s
          resource_ids = group_logic.get_fix_group_resources(
            FixGroupResourceIds::ALL_USERS, action_resource_id, search_param)
        end
      end
      
      # 基準日から1週間分の日付Listを取得
      target_dates = DateHelper::create_date_list(target_date, 7)
  
      # 取得したリソースIDListに対するスケジュール情報を取得する
      schedule_view = create_resources_schedule_view(target_dates, resource_ids, action_resource_id)
      schedule_view.target_group_resource_id = search_param.group_resource_id
      
      # ページング情報を作成
      schedule_view.link = PagerHelper.crate_page_link(
          search_param, "turnResources", "/ajax/scheduleWeekGroup/turn")
      schedule_view.total_count = search_param.total_count

      return schedule_view
    end
  end

  #
  # リソース指定月次スケジュール表示データ作成
  # 指定期間に対する、指定リソースの月次スケジュール表示データを作成します
  # ==== _Args_
  # [target_month]
  #   表示対象年月
  # [target_resource_id]
  #   表示対象リソースID
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleService::ScheduleView</i>)
  #
  def create_resource_schedule_view_month(target_month, target_resource_id, action_resource_id)
    transaction_handler do
      
      # 基準年月の日付Listを取得
      target_dates = DateHelper::create_month_date_list(target_month)
      
      schedule_view = create_resources_schedule_view(target_dates, [target_resource_id.to_i], 
        action_resource_id, target_month)
      schedule_view.target_group_resource_id = ""

      # view_date_rangeの再設定
      target_date = Date.strptime(target_month + "01", "%Y%m%d");
      schedule_view.view_date_range = target_date.strftime("%Y年%m月")
      return schedule_view
    end
  end
  
  #
  # 複数リソース指定スケジュール表示データ作成
  # 指定期間に対する、指定した複数のリソースの指定した期間のスケジュール表示データを作成します
  # ==== _Args_
  # [target_dates]
  #   表示対象日付List
  # [target_resource_ids]
  #   表示対象リソースIDList
  # [action_resource_id]
  #   ログインユーザのリソースID
  # [target_year_month]
  #   表示対象年月
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleService::ScheduleView</i>)
  #
  def create_resources_schedule_view(
    target_dates, target_resource_ids, action_resource_id, target_year_month = nil)
 
    transaction_handler do
      schedule_view = ScheduleService::ScheduleView.new
      schedule_view.view_date_range = create_view_date_range(target_dates)
      schedule_view.view_date_list = create_view_date_list(target_dates, target_year_month)
      logic = ScheduleLogic.new
      schedule_view.view_resource_schedule = 
        logic.create_resource_schedule(
          target_dates, target_resource_ids, action_resource_id)
      schedule_view.group_list = create_all_group_resource_list
      return schedule_view
    end
  end
  
  #
  # 週次スケジュールデータ
  #
  class ScheduleView
    # 表示リソースグループID
    attr_accessor :target_group_resource_id
    # グループ構成情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :group_list
    # 表示期間文字列
    attr_accessor :view_date_range
    # 表示日付List(1要素が1日分のデータ)
    # <i>ScheduleService::ViewDate</i>のlist
    attr_accessor :view_date_list
    # 表示スケジュール(1要素が1リソース分のデータ)
    # <i>ScheduleLogic::ResourceSchedule</i>のlist
    attr_accessor :view_resource_schedule


    #
    # グループの週次スケジュール表示時に設定する
    #
    
    # リンク文字列(Htmlタグ)
    attr_accessor :link
    # トータル件数
    attr_accessor :total_count

    #
    # 月次スケジュール表示時に設定する
    #
    

  end
  
  #
  # スケジュール日付データ
  #
  class ViewDate
    # 当日日付の場合、true
    attr_accessor :today
    # 土曜日の場合、true
    attr_accessor :saturday
    # 日曜日の場合、true
    attr_accessor :sunday
    # 祝日の場合、true
    attr_accessor :holiday
    # 祝日のメモ情報
    attr_accessor :holiday_memo
    # 対象日(yyyymmdd形式)
    attr_accessor :date_yyyy_mm_dd
    
    #
    # 主に週次スケジュールの際に使用
    #
    
    # 曜日名
    attr_accessor :day_of_the_week_name

    #
    # 主に月次スケジュールの際に使用
    #

    # 表示対象年月の場合、true
    attr_accessor :target_month

    #
    # コンストラクタ
    #
    def initialize
      @today = false
      @saturday = false
      @sunday = false
      @holiday = false
      @target_month = false
    end
  end
  
  #
  # 検索条件のパラメータclass
  #
  class SearchParam < Model::SearchParam
    # グループリソースID
    attr_accessor :group_resource_id

  end
  
  private

    #
    # 表示日付List生成
    # ==== _Args_
    # [target_dates]
    #   表示対象日付List
    # [target_year_month]
    #   表示対象年月
    # ==== _Return_
    # <i>ScheduleService::ViewDate</i>のlist
    #
    def create_view_date_list(target_dates, target_year_month)
      ret_list = []
      last_index = target_dates.length - 1
      logic = NationalHolidayLogic.new
      
      holidays = logic.find_by_between_date(
        target_dates[0], target_dates[last_index])
      
      holiday_hash = create_hokiday_hash(holidays)
      
      today = ApplicationHelper::get_current_date
      
      target_dates.each do |target_date|
        ret_list.push(createViewDate(target_date, holiday_hash, today, target_year_month))
      end
      return ret_list
    end

    #
    # ViewDate生成
    # ==== _Args_
    # [target_date]
    #   対象日付
    # [holiday_hash]
    #   祝日Hash
    # [today]
    #   当日日付
    # [target_year_month]
    #   対象年月
    # ==== _Return_
    # <i>ScheduleService::ViewDate</i>
    #
    def createViewDate(target_date, holiday_hash, today, target_year_month)
      view_date = ScheduleService::ViewDate.new
      holiday = holiday_hash[target_date]
      if holiday != nil
        # 対象日が祝日である場合
        view_date.holiday = true
        view_date.holiday_memo = holiday[:memo]
      end
      
      if target_date == today
        view_date.today = true
      end
      
      # 曜日を判断して設定
      wday = target_date.wday
      if wday == 0
        view_date.sunday = true
      elsif wday == 6
        view_date.saturday = true
      end
      view_date.day_of_the_week_name = DAY_OF_THE_WEEK[wday]
      
      if target_year_month != nil
        if target_year_month == target_date.strftime("%Y%m")
          view_date.target_month = true
        end
      end
      view_date.date_yyyy_mm_dd = target_date.strftime("%Y%m%d")
      return view_date
    end
    
    #
    # 祝日Hash生成
    # ==== _Args_
    # [holidays]
    #   祝日List
    # ==== _Return_
    # Keyが日付、valueが<i>NationalHoliday</i>のHash
    #
    def create_hokiday_hash(holidays)
      ret_hash = {}
      holidays.each do |holiday|
        ret_hash[holiday[:target_date]] = holiday
      end
      return ret_hash
    end

    #
    # 表示用期間文字列作成
    # ==== _Args_
    # [target_dates]
    #   表示対象日付List
    # ==== _Return_
    # 表示用期間文字列
    #
    def create_view_date_range(target_dates)
      last_index = target_dates.length - 1
      format = "%Y年%m月%d日"
      view_str = target_dates[0].strftime(format) + "〜" + target_dates[last_index].strftime(format)
      return view_str
    end
  
    #
    # グループリソース構成情報取得
    # 選択可能なグループリソースを全て取得します
    # ==== _Return_
    # 構成情報。<i>Entity::LabelValueBean</i>のlist
    #
    def create_all_group_resource_list
      ret_list = []
      ret_list.push(Entity::LabelValueBean.new("","--"))
      ret_list.push(Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_USERS, FixGroupResourceLabel::ALL_USERS_LABEL))
      ret_list.push(Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_FACILITIES, FixGroupResourceLabel::ALL_FACILITIES_LABEL))
      ret_list.push(Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_USER_GROUP, FixGroupResourceLabel::ALL_USER_GROUP_LABEL))
      
      logic = GroupLogic.new
      # ユーザグループを追加
      ret_list.concat(logic.create_all_user_group)
      # 設備グループを取得
      ret_list.concat(logic.create_all_facility_group)
      
      return ret_list
    end
end
