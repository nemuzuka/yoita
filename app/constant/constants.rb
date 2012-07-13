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
