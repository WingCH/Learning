#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 確保build目錄存在
mkdir -p build
mkdir -p test_results

# 初始化構建時間 JSON
BUILD_TIMES_FILE="$PROJECT_ROOT/test_results/build_times.json"
echo '{
  "efficient_build": {},
  "inefficient_build": {}
}' > $BUILD_TIMES_FILE

# 時間格式化函數 (兼容 macOS)
format_duration() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $secs
}

echo "===== 開始構建IPA檔案 ====="

# 構建高效版本的IPA
echo -e "\n===== 預先構建高效版本IPA ====="
START_EFFICIENT_BUILD=$(date +%s)

fvm flutter build ipa \
  --target=integration_test/efficient_list_test.dart \
  --profile \
  --export-method development

BUILD_STATUS=$?
END_EFFICIENT_BUILD=$(date +%s)
EFFICIENT_BUILD_DURATION=$((END_EFFICIENT_BUILD - START_EFFICIENT_BUILD))
EFFICIENT_BUILD_FORMATTED=$(format_duration $EFFICIENT_BUILD_DURATION)

# 更新構建時間 JSON
TMP_FILE=$(mktemp)
jq ".efficient_build = { \"total_seconds\": $EFFICIENT_BUILD_DURATION, \"formatted\": \"$EFFICIENT_BUILD_FORMATTED\", \"status\": \"$([ $BUILD_STATUS -eq 0 ] && echo "success" || echo "failed")\" }" $BUILD_TIMES_FILE > $TMP_FILE
mv $TMP_FILE $BUILD_TIMES_FILE

if [ $BUILD_STATUS -ne 0 ]; then
  echo "構建高效版本IPA失敗，退出"
  exit 1
fi

EFFICIENT_IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
echo "高效版本IPA已構建: $EFFICIENT_IPA_PATH"
echo "構建時間: $EFFICIENT_BUILD_FORMATTED"

# 備份高效版本IPA
mkdir -p build/efficient_ipa
cp -r build/ios/ipa/* build/efficient_ipa/
echo "高效版本IPA已備份到: build/efficient_ipa/"

# 構建低效版本的IPA
echo -e "\n===== 預先構建低效版本IPA ====="
START_INEFFICIENT_BUILD=$(date +%s)

fvm flutter build ipa \
  --target=integration_test/inefficient_list_test.dart \
  --profile \
  --export-method development

BUILD_STATUS=$?
END_INEFFICIENT_BUILD=$(date +%s)
INEFFICIENT_BUILD_DURATION=$((END_INEFFICIENT_BUILD - START_INEFFICIENT_BUILD))
INEFFICIENT_BUILD_FORMATTED=$(format_duration $INEFFICIENT_BUILD_DURATION)

# 更新構建時間 JSON
TMP_FILE=$(mktemp)
jq ".inefficient_build = { \"total_seconds\": $INEFFICIENT_BUILD_DURATION, \"formatted\": \"$INEFFICIENT_BUILD_FORMATTED\", \"status\": \"$([ $BUILD_STATUS -eq 0 ] && echo "success" || echo "failed")\" }" $BUILD_TIMES_FILE > $TMP_FILE
mv $TMP_FILE $BUILD_TIMES_FILE

if [ $BUILD_STATUS -ne 0 ]; then
  echo "構建低效版本IPA失敗，退出"
  exit 1
fi

INEFFICIENT_IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
echo "低效版本IPA已構建: $INEFFICIENT_IPA_PATH"
echo "構建時間: $INEFFICIENT_BUILD_FORMATTED"

# 備份低效版本IPA
mkdir -p build/inefficient_ipa
cp -r build/ios/ipa/* build/inefficient_ipa/
echo "低效版本IPA已備份到: build/inefficient_ipa/"

# 將構建時間添加到總構建時間 JSON
TOTAL_BUILD_DURATION=$((EFFICIENT_BUILD_DURATION + INEFFICIENT_BUILD_DURATION))
TOTAL_BUILD_FORMATTED=$(format_duration $TOTAL_BUILD_DURATION)
TMP_FILE=$(mktemp)
jq ".total = { \"total_seconds\": $TOTAL_BUILD_DURATION, \"formatted\": \"$TOTAL_BUILD_FORMATTED\" }" $BUILD_TIMES_FILE > $TMP_FILE
mv $TMP_FILE $BUILD_TIMES_FILE

echo -e "\n===== IPA構建完成 ====="
echo "高效版本IPA位置: build/efficient_ipa/study_flutter_performance_test.ipa"
echo "低效版本IPA位置: $INEFFICIENT_IPA_PATH (當前IPA檔案)"
echo "構建時間總結:"
echo "- 高效版本: $EFFICIENT_BUILD_FORMATTED"
echo "- 低效版本: $INEFFICIENT_BUILD_FORMATTED"
echo "- 總計: $TOTAL_BUILD_FORMATTED"
echo "構建時間已保存到: $BUILD_TIMES_FILE"
echo "可以運行 './scripts/run_performance_tests.sh' 開始測試" 