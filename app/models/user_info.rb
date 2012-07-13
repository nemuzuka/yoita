# encoding: utf-8

#
# user_infosテーブルのmodel
#
class UserInfo < ActiveRecord::Base
  attr_accessible :admin_flg, :default_user_group, :entry_resource_id, :lock_version, :mail, :per_page, :reading_character, :resource_id, :tel, :update_resource_id, :validity_end_date, :validity_start_date

  # validates
  validates :reading_character, :length => { :maximum  => 128 }
  validates :tel, :length => { :maximum  => 48 }
  validates :mail, :length => { :maximum  => 256 }
  validates :admin_flg, :length => { :maximum  => 1 }, :inclusion => { :in => ['0','1'] }
  validates :per_page, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1000 }
  validates :validity_start_date, :presence => true
  validates :validity_end_date, :presence => true

  #
  # json変換時処理.
  # json変換時に出力する項目を設定します。
  #
  def as_json(options={})
    options[:except] ||= [:created_at, :updated_at, 
      :entry_resource_id, :update_resource_id]
    super(options)
  end

  #
  # リソースIDによる取得
  # 入力されたリソースIDに紐付くloginsテーブルの情報を取得します
  # ==== _Args_
  # [resource_id]
  #   リソースID
  # ==== _Return_
  # 該当レコード
  # ==== _Raise_
  # [CustomException::NotFoundException]
  #   該当レコードが存在しない場合
  #
  def self.find_by_resource_id(resource_id)
    result = where(:resource_id => resource_id).first
    if result == nil
      raise CustomException::NotFoundException.new
    end
    return result
  end

  #
  # 検索条件に合致するレコードを抽出.
  # 検索条件として設定されている項目に対してのみWhere句に設定します。ページャ用の設定がされている場合、ページング処理を行います
  # 複数テーブルを内部結合してSQL文を発行します
  # ==== _Args_
  # [param]
  #   検索条件パラメータ(see. <i>UserInfo::SearchParam</i>)
  # ==== _Return_
  # 該当レコード(存在しない場合、size=0のList)
  #
  def self.find_by_conditions(param)
    
    sql = <<-EOS
      select 
        A.id as resource_id,
        A.name,
        A.memo,
        A.lock_version as resource_lock_version,
        B.reading_character,
        B.tel,
        B.mail,
        B.admin_flg,
        B.validity_start_date,
        B.validity_end_date,
        B.lock_version as user_info_lock_version,
        C.login_id,
        C.lock_version as login_lock_version
      from 
        resources A,
        user_infos B,
        logins C
      where
        A.id = B.resource_id and
        A.id = C.resource_id and
        A.resource_type = '001'
    EOS
    
    param_hash = {}
    # 名称(中間一致)
    if param.name.to_s != ''
      sql << " and A.name like :name "
      param_hash[:name] = "%" + SqlHelper.replase_match_string(param.name) + "%"
    end

    # ふりがな(中間一致)
    if param.reading_character.to_s != ''
      sql << " and B.reading_character like :reading_character "
      param_hash[:reading_character] = "%" + SqlHelper.replase_match_string(param.reading_character) + "%"
    end

    # 管理者のみ
    if param.admin_only != nil && param.admin_only == true
      sql << " and B.admin_flg = '1' "
    end

    # リソースID
    if param.resource_id.to_s != ""
      sql << " and A.id = :resource_id "
      param_hash[:resource_id] = param.resource_id
    end

    # リソースIDList
    if param.resource_id_list != nil && param.resource_id_list.length != 0
      sql << " and A.id in(:resource_id_list) "
      param_hash[:resource_id_list] = param.resource_id_list
    end

    # 検索方法
    if param.search_type == SearchType::EXCLUDE_DISABLE_DATA
      # 無効データは含めない
      sql << " and (B.validity_start_date <= :search_base_date and :search_base_date <= B.validity_end_date ) "
      param_hash[:search_base_date] = param.search_base_date
      
    elsif param.search_type == SearchType::ONLY_DISABLE_DATA
      # 無効データのみ
      sql << " and (B.validity_start_date > :search_base_date or :search_base_date > B.validity_end_date ) "
      param_hash[:search_base_date] = param.search_base_date
    end

    # ソート順(パラメータで変更するかもしれないけど、とりあえず固定で)
    sql << " order by A.sort_num, A.id "
    
    # 直接SQL発行
    SqlHelper::find_by_sql(sql, param_hash, self, param)
  end

  #
  # UserInfoの検索条件のパラメータclass
  #
  class SearchParam < Model::SearchParam
    # 名称
    attr_accessor :name
    # ふりがな
    attr_accessor :reading_character
    # 管理者のみフラグ
    attr_accessor :admin_only
    # リソースID
    attr_accessor :resource_id
    # リソースIDList
    attr_accessor :resource_id_list
    
    # 必須
    # 検索方法
    attr_accessor :search_type
    
    # 検索基準日
    attr_accessor :search_base_date
    
    #
    # コンストラクタ
    #
    def initialize
      @search_type = SearchType::EXCLUDE_DISABLE_DATA
      @search_base_date = ApplicationHelper::get_current_date
    end
  end

end
