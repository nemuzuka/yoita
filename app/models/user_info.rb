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

end
