#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 確保構建目錄存在
mkdir -p build
mkdir -p test_results

# 初始化構建時間 JSON
BUILD_TIMES_FILE="$PROJECT_ROOT/test_results/build_times.json"
echo '{"builds": []}' > $BUILD_TIMES_FILE

# 時間格式化函數 (兼容 macOS)
format_duration() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $secs
}

echo "===== 開始動態構建APK檔案 ====="

# 尋找 integration_test 目錄中所有的測試檔案
TEST_FILES=()
for file in "$PROJECT_ROOT/integration_test"/*.dart; do
  if [[ -f "$file" && $(basename "$file") != "_"* ]]; then
    # 排除以下划線開頭的檔案（可能是幫助檔案或其他非測試檔案）
    TEST_FILES+=("$file")
  fi
done

# 如果沒有找到測試檔案，則退出
if [ ${#TEST_FILES[@]} -eq 0 ]; then
  echo "錯誤：在 integration_test 目錄中沒有找到測試檔案"
  exit 1
fi

echo "找到 ${#TEST_FILES[@]} 個測試檔案："
for file in "${TEST_FILES[@]}"; do
  echo "- $(basename "$file")"
done

# 總構建時間
TOTAL_BUILD_DURATION=0

# 循環構建每個測試檔案的 APK
for test_file in "${TEST_FILES[@]}"; do
  test_name=$(basename "$test_file" .dart)
  echo -e "\n===== 構建 $test_name APK ====="
  START_BUILD=$(date +%s)

  # 構建 APK
  fvm flutter build apk \
    --target="$test_file" \
    --profile

  BUILD_STATUS=$?
  END_BUILD=$(date +%s)
  BUILD_DURATION=$((END_BUILD - START_BUILD))
  BUILD_DURATION_FORMATTED=$(format_duration $BUILD_DURATION)
  TOTAL_BUILD_DURATION=$((TOTAL_BUILD_DURATION + BUILD_DURATION))

  # 更新構建時間 JSON
  TMP_FILE=$(mktemp)
  jq ".builds += [{
    \"name\": \"$test_name\",
    \"file\": \"$test_file\",
    \"total_seconds\": $BUILD_DURATION,
    \"formatted\": \"$BUILD_DURATION_FORMATTED\",
    \"status\": \"$([ $BUILD_STATUS -eq 0 ] && echo "success" || echo "failed")\"
  }]" $BUILD_TIMES_FILE > $TMP_FILE
  mv $TMP_FILE $BUILD_TIMES_FILE

  if [ $BUILD_STATUS -ne 0 ]; then
    echo "構建 $test_name APK失敗，跳過"
    continue
  fi

  APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-profile.apk"
  echo "$test_name APK已構建: $APK_PATH"
  echo "構建時間: $BUILD_DURATION_FORMATTED"

  # 備份當前測試的 APK
  mkdir -p "build/${test_name}_apk"
  cp -r build/app/outputs/flutter-apk/* "build/${test_name}_apk/"
  echo "$test_name APK已備份到: build/${test_name}_apk/"
done

# 將總構建時間添加到構建時間 JSON
TOTAL_BUILD_FORMATTED=$(format_duration $TOTAL_BUILD_DURATION)
TMP_FILE=$(mktemp)
jq ".total = { \"total_seconds\": $TOTAL_BUILD_DURATION, \"formatted\": \"$TOTAL_BUILD_FORMATTED\" }" $BUILD_TIMES_FILE > $TMP_FILE
mv $TMP_FILE $BUILD_TIMES_FILE

echo -e "\n===== APK構建完成 ====="
echo "總共構建了 ${#TEST_FILES[@]} 個測試的 APK 檔案"
echo "構建時間總計: $TOTAL_BUILD_FORMATTED"
echo "構建時間詳情已保存到: $BUILD_TIMES_FILE"
echo "可以運行 './scripts/run_performance_tests.sh' 開始測試" 