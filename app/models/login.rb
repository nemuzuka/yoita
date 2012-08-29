# encoding: utf-8

require 'digest/sha2'

#
# loginsテーブルのmodel
#
class Login < ActiveRecord::Base
  attr_accessible :entry_resource_id, :lock_version, :login_id, :password, :resource_id, :update_resource_id, :provider
  
  # validates
  validates :login_id, :length => { :maximum  => 256 }, :presence => true
  validates :password, :length => { :maximum  => 256 }, :presence => true

  #
  # json変換時処理.
  # json変換時に出力する項目を設定します。
  #
  def as_json(options={})
    options[:except] ||= [:created_at, :updated_at, 
      :entry_resource_id, :update_resource_id, :password]
    super(options)
  end

  #
  # 認証.
  # 入力されたユーザIDとパスワードが合致するloginsテーブルの情報を取得します
  # アプリ認証のユーザのみ処理対象になります
  # ==== _Args_
  # [login_id]
  #   ログインID
  # [password]
  #   パスワード
  # ==== _Return_
  # 該当レコード(存在しない場合、nil)
  #
  def self.auth(login_id, password)
    where(:provider => ProviderType::YOITA,
      :login_id => login_id,
      :password => Digest::SHA512.hexdigest(password)).first
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
  # ログインIDによる取得
  # 入力されたログインIDと認証プロバイダ区分に紐付くloginsテーブルの情報を取得します
  # Facebookによる認証の際に使用することを想定しています。
  # ==== _Args_
  # [login_id]
  #   ログインID(FacebookのUID)
  # [provider]
  #   ユーザの認証プロバイダ区分 see.<i>ProviderType</i>
  # ==== _Return_
  # 該当レコード(存在しない場合、nil)
  #
  def self.find_by_login_id(login_id, provider)
    where(:provider => provider,
      :login_id => login_id).first
  end

end
