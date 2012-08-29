# encoding: utf-8

# controllers/modelsで使用する定数.

# Long値として取りうる最大値
MAX_LONG = 9223372036854775807
# Dateとして取りうる最大値
MAX_DATE = Date.strptime("2999-12-31", "%Y-%m-%d")
# 曜日名
DAY_OF_THE_WEEK = ["日", "月", "火", "水", "木", "金", "土"]

# 最小時刻
MIN_TIME = "0000"
# 最大時刻
MAX_TIME = "2359"

#
# リソース区分定数値
#
module ResourceType
  # ユーザ
  USER = "001"
  # 設備
  FACILITY = "002"
  # ユーザグループ
  USER_GROUP = "003"
  # 設備グループ
  FACILITY_GROUP = "004"
end

#
# 検索方法設定値.
#
module SearchType
  # 無効データは含めない
  EXCLUDE_DISABLE_DATA = "001"
  # 無効データも含める
  INCLUDE_DISABLE_DATA = "002"
  # 無効データのみ
  ONLY_DISABLE_DATA = "003"
end

#
# 固定グループのリソースID
# 値は負数であること
#
module FixGroupResourceIds
  # 全ユーザ
  ALL_USERS = -1
  # 全ての設備
  ALL_FACILITIES = -2
  # ユーザグループ一覧
  ALL_USER_GROUP = -3
end

#
# 固定グループのリソース名
#
module FixGroupResourceLabel
  # 全ユーザ
  ALL_USERS_LABEL = "【全ユーザ】"
  # 全ての設備
  ALL_FACILITIES_LABEL = "【全ての設備】"
  # ユーザグループ一覧
  ALL_USER_GROUP_LABEL = "【ユーザグループ一覧】"
end

#
# スケジュールの繰り返し条件
#
module RepeatConditions
  # 毎日
  EVERY_DAY = "1"
  # 毎日(土日を除く)
  EVERY_DAY_EXCLUDE_WEEKEND = "2"
  # 毎週
  EVERY_WEEK = "3"
  # 毎月
  EVERY_MONTH = "4"
end

#
# スケジュールの繰り返し条件ラベル
#
module RepeatConditionLabel
  # 毎日
  EVERY_DAY = "毎日"
  # 毎日(土日を除く)
  EVERY_DAY_EXCLUDE_WEEKEND = "毎日(土日を除く)"
  # 毎週
  EVERY_WEEK = "毎週"
  # 毎月
  EVERY_MONTH = "毎月"
end

#
# 繰り返し - 毎月の設定値
#
module RepeatMonth
  # 月末
  EndOfMonth = "32"
end

#
# 繰り返し - 毎月の設定値ラベル
#
module RepeatMonthLabel
  # 月末
  EndOfMonth = "月末"
end

#
# スケジュール表示方法
#
module ViewType
  # システム日付
  TODAY = "today"
  # 次へ
  NEXT = "next"
  # 前へ
  PREV = "prev"
end

#
# 加算単位
#
module AmountType
  # 日単位
  DAY = "day"
  # 週単位
  WEEK = "week"
end

#
# アプリケーション参照権限
#
module Authentication
  # スケジューラ管理者
  SCHEDULER_ADMIN = "scheduler_admin"
end

#
# アプリケーション参照権限比較方法
#
module AuthenticationCheckType
  # or
  OR = "or"
  # and
  AND = "and"
end

#
# ユーザの認証プロバイダ区分
#
module ProviderType
  # アプリ登録ユーザ
  YOITA = "Y"
  # Facebook
  FACEBOOK = "F"
end
