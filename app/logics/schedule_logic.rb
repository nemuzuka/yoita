# encoding: utf-8

#
# スケジュールに関するLogic
#
class ScheduleLogic

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
    # スケジュール情報を登録
    schedule = save_schedule(params, action_resource_id)
    
    # スケジュール関連情報を登録
    save_schedule_conn(schedule[:id], params[:schedule_conn])
    
    return schedule
  end

  #
  # リソース毎のスケジュール作成
  # ==== _Args_
  # [target_dates]
  #   表示対象日付List
  # [target_resource_ids]
  #   表示対象リソースIDList
  # [action_resource_id]
  #   ログインユーザのリソースID
  # ==== _Return_
  # <i>ScheduleLogic::ResourceSchedule</i>のList
  #
  def create_resource_schedule(target_dates, target_resource_ids, action_resource_id)
    
    if target_resource_ids.length == 0
      return []
    end
    
    start_date = target_dates[0]
    end_date = target_dates[target_dates.length - 1]
    
    # スケジュール取得対象リソース情報を取得
    # 非公開スケジュールが参照できるか判断する為、
    # ログインユーザのリソースIDも取得条件に組み込む必要がある
    resource_ids = SortedSet.new.merge(target_resource_ids).add(action_resource_id).to_a
    schedule_list = Schedule.get_schedule_list(resource_ids, start_date, end_date)
    
    # リソース情報を取得
    resource_hash = Resource.create_resource_hash(resource_ids)

    # スケジュール情報を作成
    target_schedule = create_target_schedule(schedule_list)

    # リソース毎のスケジュール情報を作成
    create_resource_schedule_list(target_dates, target_resource_ids, 
      resource_hash, target_schedule, action_resource_id)
  end

  #
  # リソース毎のスケジュール保持クラス.
  #
  class ResourceSchedule
    # リソースID
    attr_accessor :resource_id
    # リソース名
    attr_accessor :name
    # リソース区分
    attr_accessor :resource_type
    # 対象リソースの表示対象期間のスケジュール
    # <i>ScheduleLogic::DaySchedule</i>のlist
    # Listの1要素が1日分のデータ。スケジュールが存在しなくても、要素を追加する
    attr_accessor :schedule_list

    #
    # コンストラクタ
    #
    def initialize
      @schedule_list = []
    end
  end

  #
  # 1日辺りの表示スケジュール保持クラス.
  #
  class DaySchedule
    # 時間指定なしスケジュールList
    # <i>ScheduleLogic::DaySchedule::ViewSchedule</i>のlist
    attr_accessor :no_time_list

    # 時間指定ありスケジュールList
    # <i>ScheduleLogic::DaySchedule::ViewSchedule</i>のlist
    attr_accessor :time_list
    
    #
    # コンストラクタ
    #
    def initialize
      @no_time_list = []
      @time_list = []
    end
    
    #
    # スケジュール表示情報.
    #
    class ViewSchedule
      # スケジュールID
      attr_accessor :schedule_id
      # 表示件名
      attr_accessor :view_title
      # 重複している場合、true
      attr_accessor :duplicate
      # 開始時刻
      attr_accessor :start_time
      # 終了時刻
      attr_accessor :end_time
      
      #
      # コンストラクタ
      #
      def initialize
        @duplicate = false
      end
    end
  end

  protected
  
    #
    # スケジュール登録・更新
    # ==== _Args_
    # [params]
    #   スケジュール登録・更新情報
    # [action_resource_id]
    #   登録・更新処理実行ユーザリソースID
    # ==== _Return_
    # 処理レコード
    # ==== _Raise_
    # [CustomException::ValidationException]
    #   validate時の例外
    # [CustomException::IllegalParameterException]
    #   不正なパラメータを渡された場合
    # [CustomException::NotFoundException]
    #   該当レコードが存在しない場合
    # [CustomException::InvalidVersionException]
    #   バージョンが合わない場合(更新時)
    #
    def save_schedule(params, action_resource_id)  
      schedule = nil
      id = params[:schedule][:id]
      
      # validate
      validate_schedule(params)
      
      if id.to_s == ''
        # 新規登録の場合
        schedule = Schedule.new(params[:schedule])
        schedule[:entry_resource_id] = action_resource_id
        schedule[:update_resource_id] = action_resource_id
        begin
          schedule.save!
        rescue ActiveRecord::RecordInvalid => e
          raise CustomException::ValidationException.new(e.record.errors.full_messages)
        end
      else
        # 更新の場合
        logic = ScheduleDetailLogic.new
        detail = logic.get_detail(id, action_resource_id)
        
        schedule = detail.schedule
        schedule[:title] = nil
        
        # 更新するカラムを指定して、更新を行う
        clone_pamam = params[:schedule].clone
        clone_pamam[:update_resource_id] = action_resource_id

        begin
          
          begin
            schedule.update_attributes!(
                  clone_pamam.except(:entry_resource_id))
          rescue ActiveRecord::RecordInvalid => e
            raise CustomException::ValidationException.new(e.record.errors.full_messages)
          end
        
        rescue ActiveRecord::StaleObjectError
          # lock_versionが不正の場合、バージョンエラーのExceptionをthrow
          raise CustomException::InvalidVersionException.new
        end
      end

      return schedule
    end
  
    #
    # スケジュール関連データ登録
    # 全て削除した後、新しく登録します
    # ==== _Args_
    # [schedule_id]
    #   スケジュールID
    # [schedule_conn]
    #   スケジュール関連設定対象リソースIDList
    #
    def save_schedule_conn(schedule_id, schedule_conn)
      ScheduleConn.delete_by_schedule_id(schedule_id)
      ScheduleConn.insert_conn_list(schedule_id, schedule_conn)
    end
  
    # リソース毎のスケジュールList作成
    # ==== _Args_
    # [target_dates]
    #   表示対象日付List
    # [target_resource_ids]
    #   表示対象リソースIDList
    # [resource_hash]
    #   処理対象リソースHash
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [action_resource_id]
    #   ログインユーザのリソースID
    # ==== _Return_
    # <i>ScheduleLogic::ResourceSchedule</i>のList
    def create_resource_schedule_list(target_dates, target_resource_ids, resource_hash, 
      target_schedule, action_resource_id)
      
      ret = []      
      target_resource_ids.each do |resource_id|
        
        if resource_hash.key?(resource_id.to_i) == false
          # 指定したリソースIDが存在しない場合、Listに含めない
          next
        end
        
        ret.push(
          create_resrouce_schedule_record(
            target_dates, resource_hash[resource_id.to_i], target_schedule, action_resource_id)
        )
      end
      return ret
    end
  
    # 対象リソースのスケジュール作成
    # ==== _Args_
    # [target_dates]
    #   表示対象日付List
    # [target_resource]
    #   処理対象リソース
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [action_resource_id]
    #   ログインユーザのリソースID
    # ==== _Return_
    # <i>ScheduleLogic::ResourceSchedule</i>
    def create_resrouce_schedule_record(target_dates, target_resource, target_schedule, action_resource_id)
      ret = ScheduleLogic::ResourceSchedule.new
      
      ret.resource_id = target_resource[:id]
      ret.name = target_resource[:name]
      ret.resource_type = target_resource[:resource_type]
      
      # 対象日付分の日付を追加する
      target_dates.each do |target_date|
        ret.schedule_list.push(ScheduleLogic::DaySchedule.new)
      end
      
      schedule_id_set = target_schedule.resource_schedule_hash[target_resource[:id]]
      if schedule_id_set == nil || schedule_id_set.length == 0
        return ret
      end
      # スケジュールを登録する
      schedule_id_set.each do |target_schedule_id|
        set_resource_schedule(ret, target_schedule_id, target_dates, target_schedule, action_resource_id)
      end
      # スケジュールの重複設定
      set_duplicate_mark(ret)

      return ret
    end
    
    #
    # 重複スケジュール設定
    # 時刻指定有りのスケジュールに対して、重複フラグを付与します
    # ==== _Args_
    # [resource_schedule]
    #   設定インスタンス<i>ScheduleLogic::ResourceSchedule</i>
    #
    def set_duplicate_mark(resource_schedule)
      schedule_list = resource_schedule.schedule_list
      schedule_list.each do |day_schedule|
        # 時刻設定有りのスケジュールのみ処理対象
        time_list = day_schedule.time_list
        list_size = time_list.length
        time_list.each_with_index do |from_view_schedule, i|
          
          j = (i + 1)
          while j < list_size do
            to_view_schedule = time_list[j]
            
            if from_view_schedule.duplicate == false || 
              to_view_schedule.duplicate == false

              # 被っている場合、重複チェックを付与
              if DateHelper::range_check(from_view_schedule.start_time, from_view_schedule.end_time,
                to_view_schedule.start_time, to_view_schedule.end_time) == true
                
                from_view_schedule.duplicate = true
                to_view_schedule.duplicate = true
              end
            end

            j += 1
          end
        end
      end
    end

    #
    # リソーススケジュール設定
    # スケジュールを設定します
    # ==== _Args_
    # [resource_schedule]
    #   設定インスタンス<i>ScheduleLogic::ResourceSchedule</i>
    # [target_schedule_id]
    #   設定対象スケジュールID
    # [target_dates]
    #   表示対象日付List
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [action_resource_id]
    #   ログインユーザのリソースID
    #
    def set_resource_schedule(resource_schedule, target_schedule_id, target_dates, target_schedule, action_resource_id)
      
      schedule = target_schedule.schedule_hash[target_schedule_id]
      
      target_dates.each_with_index do |target_date, index|
        # 対象日付毎に設定するかを判断する
        
        if schedule[:start_date] > target_date || target_date > schedule[:end_date]
          # 範囲外の場合、次の日付へ
          next
        end
        
        if schedule[:repeat_conditions].to_s == ''
          # 非繰り返しのスケジュールに登録
          set_schedule(index, resource_schedule, target_date, schedule, target_schedule, action_resource_id)
        else
          # 繰り返しスケジュールに登録
          set_repeat_schedule(index, resource_schedule, target_date, schedule, target_schedule, action_resource_id)
        end
        
      end

    end
    
    #
    # スケジュール設定(繰り返し)
    # ==== _Args_
    # [index]
    #   設定日位置
    # [resource_schedule]
    #   設定インスタンス<i>ScheduleLogic::ResourceSchedule</i>
    # [target_date]
    #   設定日
    # [schedule]
    #   設定対象スケジュール
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [action_resource_id]
    #   ログインユーザのリソースID
    #
    def set_repeat_schedule(index, resource_schedule, target_date, schedule, target_schedule, action_resource_id)
      if add_schedule?(schedule, target_date) == false
        # 設定日が繰り返し登録条件に合致する日でない場合、処理終了
        return
      end
      
      day_schedule = resource_schedule.schedule_list[index]
      view_schedule = ScheduleLogic::DaySchedule::ViewSchedule.new
      view_title = ""

      if schedule[:start_time].to_s != ''
        # 時刻の設定がある場合
        
        # 時刻設定有りのListに追加
        day_schedule.time_list.push(view_schedule)

        view_title = 
          DateHelper::format_time(schedule[:start_time]) + "-" + 
            DateHelper::format_time(schedule[:end_time]) + " "
        view_schedule.start_time = schedule[:start_time]
        view_schedule.end_time = schedule[:end_time]
      else
        # 時刻の設定が無い場合

        # 時刻設定無しのListに追加
        day_schedule.no_time_list.push(view_schedule)
        view_title = "・"
      end

      set_view_schedule_data(view_schedule, schedule, target_schedule, view_title, action_resource_id)
    end
    
    #
    # スケジュール設定対象日か？
    # ==== _Args_
    # [schedule]
    #   対象スケジュール
    # [target_date]
    #   対象日
    # ==== _Return_
    # スケジュール設定対象日の場合、true
    #
    def add_schedule?(schedule, target_date)
      ret = false
      case schedule[:repeat_conditions]
      when RepeatConditions::EVERY_DAY
        # 無条件で設定
        ret = true

      when RepeatConditions::EVERY_DAY_EXCLUDE_WEEKEND
        # 土日以外であれば設定
        if target_date.wday != 0 && target_date.wday != 6
          ret = true
        end

      when RepeatConditions::EVERY_WEEK
        # 曜日が合っていれば設定
        if schedule[:repeat_week] == target_date.wday.to_s
          ret = true
        end
        
      when RepeatConditions::EVERY_MONTH
        if schedule[:repeat_day] == RepeatMonth::EndOfMonth
          # 月末指定で、対象日が月末であれば設定
          if DateHelper::create_end_of_month(target_date).strftime("%d") == target_date.strftime("%d")
            ret = true
          end
        else
          # 日付指定で、対象日がその日であれば設定
          if target_date.strftime("%d") == schedule[:repeat_day]
            ret = true
          end
        end
      end
      return ret

    end
    
    #
    # スケジュール設定(非繰り返し)
    # ==== _Args_
    # [index]
    #   設定日位置
    # [resource_schedule]
    #   設定インスタンス<i>ScheduleLogic::ResourceSchedule</i>
    # [target_date]
    #   設定日
    # [schedule]
    #   設定対象スケジュール
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [action_resource_id]
    #   ログインユーザのリソースID
    #
    def set_schedule(index, resource_schedule, target_date, schedule, target_schedule, action_resource_id)
      day_schedule = resource_schedule.schedule_list[index]
      view_schedule = ScheduleLogic::DaySchedule::ViewSchedule.new
      view_title = ""

      if schedule[:start_time].to_s != ''
        # 時刻の設定がある場合
        
        # 時刻設定有りのListに追加
        day_schedule.time_list.push(view_schedule)
        
        if target_date == schedule[:start_date] && target_date == schedule[:end_date]
          # 表示対象日付 = スケジュール開始日 = スケジュール終了日
          view_title = 
            DateHelper::format_time(schedule[:start_time]) + "-" + 
              DateHelper::format_time(schedule[:end_time]) + " "
          view_schedule.start_time = schedule[:start_time]
          view_schedule.end_time = schedule[:end_time]

        elsif target_date == schedule[:start_date] && target_date != schedule[:end_date]
          # 表示対象日付=スケジュール開始日≠スケジュール終了日
          # 開始時刻-終了日 を追加

          view_title = 
            DateHelper::format_time(schedule[:start_time]) + "-" + 
              schedule[:end_date].strftime("%m/%d") + " "
          view_schedule.start_time = schedule[:start_time]
          view_schedule.end_time = MAX_TIME
          
        elsif schedule[:start_date] < target_date && target_date < schedule[:end_date]
          # スケジュール開始日 < 表示対象日付 < スケジュール終了日
          # 開始日-終了日 を追加
          
          view_title = 
            schedule[:start_date].strftime("%m/%d") + "-" + 
              schedule[:end_date].strftime("%m/%d") + " "
          view_schedule.start_time = MIN_TIME
          view_schedule.end_time = MAX_TIME
          
        elsif target_date != schedule[:start_date] && target_date == schedule[:end_date]
          # 表示対象日付 = スケジュール終了日 != スケジュール開始日
          # 開始日-終了時刻 を追加

          view_title = 
            schedule[:start_date].strftime("%m/%d") + "-" + 
              DateHelper::format_time(schedule[:end_time]) + " "
          view_schedule.start_time = MIN_TIME
          view_schedule.end_time = schedule[:end_time]
        end
      else
        # 時刻の設定が無い場合

        # 時刻設定無しのListに追加
        day_schedule.no_time_list.push(view_schedule)
        view_title = "・"
      end

      set_view_schedule_data(view_schedule, schedule, target_schedule, view_title, action_resource_id)
    end
    
    #
    # スケジュールデータ設定
    # 非公開フラグを参照して、表示する件名を制御します
    # ログインユーザが参加していない非公開のスケジュールは、非公開と表示するのみとします
    # ==== _Args_
    # [view_schedule]
    #   スケジュールデータ(see. <i>ScheduleLogic::DaySchedule::ViewSchedule</i>)
    # [schedule]
    #   設定対象スケジュール
    # [target_schedule]
    #   処理対象スケジュールデータ
    # [view_title]
    #   タイトル
    # [action_resource_id]
    #   ログインユーザのリソースID
    #
    def set_view_schedule_data(view_schedule, schedule, target_schedule, view_title, action_resource_id)
      schedule_title = view_title + schedule[:title]
      schedule_id = schedule[:id]
      
      if schedule[:closed_flg] == '1'
        # 非公開の場合
        resource_set = target_schedule.schedule_resource_hash[schedule_id]
        if resource_set == nil || resource_set.member?(action_resource_id.to_i) == false
          # ログインユーザが参加しているスケジュールでなければ参照させない
          schedule_title = view_title + "非公開"
          schedule_id = nil
        else
          schedule_title = schedule_title + "(非公開)"
        end
      end
      view_schedule.schedule_id = schedule_id
      view_schedule.view_title = schedule_title
    end
  
    #
    # 処理対象スケジュールデータ作成
    # ==== _Args_
    # [schedule_list]
    #   スケジュールデータ
    # ==== _Return_
    # <i>ScheduleLogic::TargetSchedule</i>
    #
    def create_target_schedule(schedule_list)
      target_schedule = ScheduleLogic::TargetSchedule.new
      schedule_list.each do |target|
        
        schedule_hash = create_schedule_hash(target)
        if target_schedule.schedule_hash.has_key?(schedule_hash[:id]) == false
          # 登録されていなければhashに追加
          target_schedule.schedule_hash[schedule_hash[:id]] = schedule_hash
        end
        
        # スケジュール毎の参加リソースに追加
        resource_set = target_schedule.schedule_resource_hash[schedule_hash[:id]]
        if resource_set == nil
          resource_set = Set.new
          target_schedule.schedule_resource_hash[schedule_hash[:id]] = resource_set
        end
        resource_set.add(schedule_hash[:resource_id])
        # 非公開のスケジュールの場合、登録者も参照できる用にする為、登録
        resource_set.add(schedule_hash[:entry_resource_id])
        
        # リソースに紐付くスケジュールを追加
        schedule_set = target_schedule.resource_schedule_hash[schedule_hash[:resource_id]]
        if schedule_set == nil
          schedule_set = Set.new
          target_schedule.resource_schedule_hash[schedule_hash[:resource_id]] = schedule_set
        end
        schedule_set.add(schedule_hash[:id])
      end
      return target_schedule
    end
    
    #
    # 処理対象スケジュール管理class
    #
    class TargetSchedule
      # 全スケジュールHash
      # keyはスケジュールID、valueはスケジュール(Hash)
      attr_accessor :schedule_hash
      
      # スケジュール - リソースHash
      # スケジュールを参照できるリソースを管理します
      # keyはスケジュールID、valueはリソースIDSet
      attr_accessor :schedule_resource_hash
      
      # リソース - スケジュールHash
      # リソースに紐付くスケジュールを管理します
      # keyはリソースID、valueはスケジュールIDSet
      attr_accessor :resource_schedule_hash
      
      #
      # コンストラクタ
      #
      def initialize
        @schedule_hash = {}
        @schedule_resource_hash = {}
        @resource_schedule_hash = {}
      end
      
    end
    
  private
    #
    # スケジュールHash作成
    # ==== _Args_
    # [schedule]
    #   SQLの結果(1レコード)
    # ==== _Return_
    # スケジュールHash
    #
    def create_schedule_hash(schedule)
      ret = {}
      ret[:id] = schedule[:id].to_i
      ret[:title] = schedule[:title]
      ret[:closed_flg] = schedule[:closed_flg]
      ret[:start_date] = schedule[:start_date]
      ret[:start_time] = schedule[:start_time]
      ret[:end_date] = schedule[:end_date]
      ret[:end_time] = schedule[:end_time]
      ret[:repeat_conditions] = schedule[:repeat_conditions]
      ret[:repeat_week] = schedule[:repeat_week]
      ret[:repeat_day] = schedule[:repeat_day]
      ret[:repeat_endless] = schedule[:repeat_endless]
      ret[:entry_resource_id] = schedule[:entry_resource_id].to_i
      ret[:resource_id] = schedule[:resource_id].to_i
      return ret
    end

    #
    # schedule登録・更新validate
    # 不正なパラメータの場合、例外をthrowします
    # ==== _Args_
    # [params]
    #   リクエストパラメータ
    #
    def validate_schedule(params)
      schedule = params[:schedule]
      
      # 時刻のフォーマットチェック
      if DateHelper::time_string?(schedule[:start_time]) == false
          raise CustomException::ValidationException.new(["スケジュール開始時刻が不正です。"])
      end
      if DateHelper::time_string?(schedule[:end_time]) == false
          raise CustomException::ValidationException.new(["スケジュール終了時刻が不正です。"])
      end
      
      # 時刻の片方の入力はNG
      if (schedule[:start_time].to_s == '' && schedule[:end_time].to_s != '') || 
        (schedule[:start_time].to_s != '' && schedule[:end_time].to_s == '')
        
          raise CustomException::ValidationException.new(
            ["時刻を設定する場合はスケジュール開始時刻とスケジュール終了時刻を入力してください。"])
      end
      
      if params[:repeat].to_s == '0'
        # 繰り返しでない場合、繰り返しの情報を初期化
        schedule[:repeat_conditions] = ''
        schedule[:repeat_week] = ''
        schedule[:repeat_day] = ''
        schedule[:repeat_endless] = ''
        
        # 終了日が未設定の場合、エラー
        if schedule[:end_date].to_s == ''
          raise CustomException::ValidationException.new(["終了日は必須です。"])
        end
        
        if schedule[:start_date] == schedule[:end_date] && schedule[:start_time].to_s != ''
          # 開始日 = 終了日でかつ、時刻が入力されている場合、開始時刻 <= 終了時刻の関係であること
          if schedule[:start_time] > schedule[:end_time]
            raise CustomException::ValidationException.new(["終了時刻は開始時刻以降の時間を指定して下さい。"])
          end
        end
        
        
      elsif params[:repeat].to_s == '1'
        # 繰り返しの場合、繰り返しのデータチェック
        case schedule[:repeat_conditions]
        when RepeatConditions::EVERY_WEEK
          # 毎週の繰り返し
          repeat_week = schedule[:repeat_week].to_i
          if repeat_week < 0 || repeat_week > 6
            raise CustomException::ValidationException.new(["繰り返し曜日の指定が不正です"])
          end
        when RepeatConditions::EVERY_MONTH
          # 毎月の繰り返し
          repeat_day = schedule[:repeat_day].to_i
          if schedule[:repeat_day].length != 2 || (repeat_day < 1 || repeat_day > 32)
            raise CustomException::ValidationException.new(["繰り返し日の指定が不正です"])
          end
        end
      else
        raise CustomException::IllegalParameterException.new
      end
      
      if params[:repeat].to_s == '1' 
        # 繰り返しの場合
        if schedule[:repeat_endless] == '1'
          # 無期限スケジュールの場合、スケジュール終了日を最大日付に設定
          schedule[:end_date] = MAX_DATE.strftime("%Y/%m/%d")
        else
          # 無期限でなく、終了日が未設定の場合、エラー
          if schedule[:end_date].to_s == ''
            raise CustomException::ValidationException.new(["終了日は必須です。"])
          end
        end
        
        if schedule[:start_time].to_s != ''
          # 時刻が入力されている場合、開始時刻 <= 終了時刻の関係であること
          if schedule[:start_time] > schedule[:end_time]
            raise CustomException::ValidationException.new(["終了時刻は開始時刻以降の時間を指定して下さい。"])
          end
        end
        
      end
      
      # 開始日<=終了日の関係であること
      if schedule[:start_date] > schedule[:end_date]
        raise CustomException::ValidationException.new(["終了日は開始日以降の日付を指定して下さい。"])
      end
      
      # スケジュール参加者のチェック
      schedule_conn = params[:schedule_conn]
      if schedule_conn == nil || schedule_conn.length == 0
        raise CustomException::ValidationException.new(["スケジュールに紐づくユーザもしくは設備を1件以上設定して下さい。"])
      end
    end

end