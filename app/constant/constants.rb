# controllers/modelsで使用する定数.

# Long値として取りうる最大値
MAX_LONG = 9223372036854775807
# Dateとして取りうる最大値
MAX_DATE = Date.strptime("2999-12-31", "%Y-%m-%d")

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