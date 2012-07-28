# encoding: utf-8
require "constants"
require "service"
require "model"

#
# スケジュール詳細に対するService
#
class ScheduleDetailService < Service::Base
  
  #
  # スケジュール詳細データ取得
  # ==== _Args_
  # [schedule_id]
  #   スケジュールID
  # [target_date]
  #   スケジュール開始初期値(新規の場合のみ有効)
  # [target_resource_id]
  #   スケジュール参加初期リソース(新規の場合のみ有効)
  # [user_info]
  #   ログインユーザ情報
  # ==== _Return_
  # 該当レコード(see. <i>ScheduleDetailService::Detail</i>)
  #
  def get_detail(schedule_id, target_date, target_resource_id, user_info)
    transaction_handler do
      logic = ScheduleDetailLogic.new
      detail = logic.get_detail(schedule_id, user_info.resource_id)
      
      if schedule_id.to_s == ''
        # 新規の場合、初期値を設定
        detail.schedule_conn_set.add(target_resource_id.to_i)
        date = Date.strptime(target_date, "%Y/%m/%d")
        detail.schedule[:start_date] = date
        detail.schedule[:end_date] = date
      end
      
      create_detail(detail, user_info)
      
    end
  end
  
  #
  # グループ選択値に紐付くリソース情報取得
  # ==== _Args_
  # [selected_group]
  #   グループ選択値
  # [include_parent]
  #   戻り値に親リソースIDが子リソースIDのものを含める場合、true(ユーザグループの場合のみ有効)
  # ==== _Return_
  # <i>Entity::LabelValueBean</i>のlist
  #
  def create_group_conn_list(selected_group, include_parent)
    transaction_handler do
      resource_id = selected_group.to_i
      ret_list = []
      logic = GroupLogic.new
      if resource_id < 0
        # 固定値の取得
        list = logic.get_fix_group_resource_list(resource_id)
        list.each do |target|
          ret_list.push(Entity::LabelValueBean.new(target[:id], target[:name]))
        end
      else
        # 指定グループの取得
        ret_list = logic.get_group_resource_list(resource_id, include_parent)
      end
      return ret_list
    end
  end
  
  #
  # 詳細データ
  #
  class Detail
    # スケジュール
    attr_accessor :schedule
    
    #
    # 詳細表示用データ
    #

    # 表示用日付文字列
    attr_accessor :view_date
    
    # スケジュール登録者名
    attr_accessor :entry_resource_name
    # スケジュール更新者名
    attr_accessor :update_resource_name
    # スケジュール登録時刻
    attr_accessor :entry_time
    # スケジュール更新時刻
    attr_accessor :update_time

    
    # スケジュール参加ユーザリソース関連
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :schedule_user_conn_list
    
    # スケジュール参加設備リソース関連
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :schedule_facilities_conn_list
    
    # 全ユーザグループList
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :user_group_list
    
    # ユーザグループ選択値
    attr_accessor :selected_user_group
    
    # ユーザグループ選択値に紐付くリソース情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :user_group_conn_list
    
    
    # 全設備グループList
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :facilities_group_list

    # 設備グループ選択値
    attr_accessor :selected_facilities_group

    # 設備グループ選択値に紐付くリソース情報
    # <i>Entity::LabelValueBean</i>のlist
    attr_accessor :facilities_group_conn_list
    
  end
  
  private 

    #
    # 詳細データ取得
    # ==== _Args_
    # [detail]
    #   スケジュール詳細データ
    # [user_info]
    #   ログインユーザ情報
    # ==== _Return_
    # 詳細データ(see. <i>ScheduleDetailService::Detail</i>)
    # 
    #
    def create_detail(detail, user_info)
      ret = ScheduleDetailService::Detail.new
      ret.schedule = detail.schedule
      
      # 名称を取得する為に、スケジュールに紐付くリソースIDと登録、更新者のリソースIDをまとめる
      resource_id_set = SortedSet.new.merge(detail.schedule_conn_set)
      resource_id_set.add(ret.schedule[:entry_resource_id]) if ret.schedule[:entry_resource_id] != nil
      resource_id_set.add(ret.schedule[:update_resource_id]) if ret.schedule[:update_resource_id] != nil
      resource_id_set.add(user_info.default_user_group) if user_info.default_user_group != nil
      
      # リソースIDの一覧を取得し、hash化
      logic = ResourceLogic.new
      resource_list = logic.get_resources(resource_id_set)
      resource_hash = {}
      resource_list.each do |target|
        resource_hash[target[:id].to_i] = target
      end
      
      # スケジュールに紐付くリソース情報を作成
      ret.schedule_user_conn_list = []
      ret.schedule_facilities_conn_list = []
      detail.schedule_conn_set.each do |target_resource_id|
        resource_id = target_resource_id.to_i
        target = resource_hash[resource_id]
        if target == nil
          next
        end

        # リソース区分を参照して、設定先がユーザ or 設備かを判断し、設定する
        target_conn_list = nil
        case target[:resource_type]
        when ResourceType::USER, ResourceType::USER_GROUP
          target_conn_list = ret.schedule_user_conn_list
        when ResourceType::FACILITY
          target_conn_list = ret.schedule_facilities_conn_list
        end
        target_conn_list.push(Entity::LabelValueBean.new(target[:id], target[:name]))
      end

      # スケジュールの表示用データを設定
      set_schedule_view_data(ret, resource_hash)
      
      # ユーザグループの構成情報を作成する
      ret.user_group_list = create_user_group_list
      # 設備グループの構成情報を作成する
      ret.facilities_group_list = create_facilities_group_list
      
      # ユーザグループ選択値を設定
      ret.selected_user_group = user_info.default_user_group
      # 存在しない場合、全てのユーザとする
      if ret.selected_user_group == nil || resource_hash.has_key?(ret.selected_user_group) == false
        ret.selected_user_group = FixGroupResourceIds::ALL_USERS
      end
      
      # 設備グループ選択値を設定
      if ret.facilities_group_list.length > 2
        # 2件より多い場合、設備グループの先頭が選択値
        ret.selected_facilities_group = ret.facilities_group_list[2].key
      else
        # 2件以下の場合、全ての設備が選択値
        ret.selected_facilities_group = FixGroupResourceIds::ALL_FACILITIES
      end
      
      # ユーザグループの選択値に紐付くリソース一覧を取得
      ret.user_group_conn_list = create_group_conn_list(ret.selected_user_group, true)
      
      # 設備グループの選択値に紐付くリソース一覧を取得
      ret.facilities_group_conn_list = create_group_conn_list(ret.selected_facilities_group, true)
      return ret
    end
    
    #
    # 表示用スケジュールデータ作成
    # ==== _Args_
    # [ret]
    #   詳細データ(see. <i>ScheduleDetailService::Detail</i>)
    # [resource_hash]
    #   リソースHash
    #
    def set_schedule_view_data(ret, resource_hash)
      # 登録者の設定
      ret.entry_resource_name = get_resource_name(ret.schedule[:entry_resource_id], resource_hash)
      # 更新者の設定
      ret.update_resource_name = get_resource_name(ret.schedule[:update_resource_id], resource_hash)
      
      # 登録時刻の設定
      ret.entry_time = DateHelper::get_formated_time(ret.schedule[:created_at])
      # 更新時刻の設定
      ret.update_time = DateHelper::get_formated_time(ret.schedule[:updated_at])
      
      # 表示用期間の設定
      ret.view_date = create_view_date(ret.schedule)
    end
    
    #
    # 表示用日付文字列作成
    # ==== _Args_
    # [schedule]
    #   スケジュールデータ
    # ==== _Return_
    # 表示用日付文字列
    # 
    def create_view_date(schedule)
      if schedule[:id].to_s == ''
        return ""
      end
      
      view_date = ""
      
      if schedule[:repeat_conditions].to_s == ''
        # 繰り返しが設定されていない場合
        if schedule[:start_date] == schedule[:end_date]
          # 開始日 = 終了日の場合
          view_date = schedule[:start_date].strftime("%Y年%m月%d日")
          
          if schedule[:start_time].to_s != ''
            # 時刻が設定されている場合
            view_date = view_date + " " + DateHelper::format_time(schedule[:start_time]) + 
              " 〜 " + DateHelper::format_time(schedule[:end_time])
          end
        else
          # 開始日 ≠ 終了日の場合
          if schedule[:start_time].to_s != ''
            # 時刻が設定されている場合
            view_date = schedule[:start_date].strftime("%Y年%m月%d日") + " " + DateHelper::format_time(schedule[:start_time]) +  
              " " +" 〜 " + schedule[:end_date].strftime("%Y年%m月%d日") + " " + DateHelper::format_time(schedule[:end_time])

          else
            # 時刻が設定されてない場合
            view_date = schedule[:start_date].strftime("%Y年%m月%d日") + " 〜 " + 
              schedule[:end_date].strftime("%Y年%m月%d日")
          end
        end
        
      else
        # 繰り返しが設定されている場合
        label = ""
        case schedule[:repeat_conditions]
        when RepeatConditions::EVERY_DAY
          label = RepeatConditionLabel::EVERY_DAY
          
        when RepeatConditions::EVERY_DAY_EXCLUDE_WEEKEND
          label = RepeatConditionLabel::EVERY_DAY_EXCLUDE_WEEKEND
          
        when RepeatConditions::EVERY_WEEK
          label = RepeatConditionLabel::EVERY_WEEK + " " + 
            DAY_OF_THE_WEEK[schedule[:repeat_week].to_i] + "曜日"
          
        when RepeatConditions::EVERY_MONTH
          label = RepeatConditionLabel::EVERY_MONTH + " "
          
          if schedule[:repeat_day] == RepeatMonth::EndOfMonth
            label += RepeatMonthLabel::EndOfMonth
          else
            label += schedule[:repeat_day].to_i.to_s + "日"
          end
        end
        
        time_str = ""
        if schedule[:start_time].to_s != ''
          # 時刻が設定されている場合
          time_str = " " + DateHelper::format_time(schedule[:start_time]) + 
            " 〜 " + DateHelper::format_time(schedule[:end_time])
        end
        
        end_date_str = ""
        if schedule[:repeat_endless] == '1'
          end_date_str = " (無期限)"
        else
          end_date_str = " (" + schedule[:end_date].strftime("%Y年%m月%d日") +" まで)"
        end
        view_date = label + time_str + end_date_str
      end
      
      return view_date
    end

    #
    # リソース名称取得
    # ==== _Args_
    # [resource_id]
    #   リソースID
    # [resource_hash]
    #   リソースHash
    # ==== _Return_
    # リソース名称(該当データが存在しなければ空文字)
    #
    def get_resource_name(resource_id, resource_hash)
      if resource_id.to_s == ''
        return ""
      end
      
      name = ''
      target = resource_hash[resource_id.to_i]
      if target != nil
        name = target[:name]
      end
      
    end
    
    #
    # ユーザグループList作成
    # 全てのユーザグループ情報＋「全てのユーザ」「全てのユーザグループ」を指定します
    # ==== _Return_
    # <i>Entity::LabelValueBean</i>のlist
    #
    def create_user_group_list
      logic = GroupLogic.new
      list = logic.create_all_user_group
      # 全てのユーザ、全てのユーザグループ要素を追加する
      list.insert(1, Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_USER_GROUP, FixGroupResourceLabel::ALL_USER_GROUP_LABEL))
      list.insert(1, Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_USERS, FixGroupResourceLabel::ALL_USERS_LABEL))
      return list
    end

    #
    # 設備グループList作成
    # 全ての設備グループ情報＋「全ての設備」を指定します
    # ==== _Return_
    # <i>Entity::LabelValueBean</i>のlist
    #
    def create_facilities_group_list
      logic = GroupLogic.new
      list = logic.create_all_facility_group
      # 全ての設備要素を追加する
      list.insert(1, Entity::LabelValueBean.new(
        FixGroupResourceIds::ALL_FACILITIES, FixGroupResourceLabel::ALL_FACILITIES_LABEL))
      return list
    end
  
end
