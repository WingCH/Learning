#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 創建結果目錄
mkdir -p test_results
mkdir -p test_results/ios

# 時間格式化函數 (兼容 macOS)
format_duration() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $secs
}

# 要運行的測試次數
TEST_COUNT=1

# 獲取設備 ID
get_device_id() {
  # 使用 xcrun xctrace 獲取可用的 iOS 設備清單
  local devices=$(xcrun xctrace list devices)
  
  # 尋找第一個 iPhone 或 iPad 設備
  local device_id=$(echo "$devices" | grep -E 'iPhone|iPad' | grep -v "Simulator" | head -1 | sed -E 's/^.* ([A-Fa-f0-9\-]+)$/\1/')
  
  if [ -z "$device_id" ]; then
    echo "無法自動找到連接的 iOS 設備。"
    echo "請手動指定設備 ID，可以通過運行 'xcrun xctrace list devices' 獲取："
    read -p "設備 ID: " device_id
  fi
  
  echo "$device_id"
}

# 獲取設備 ID
DEVICE_ID=$(get_device_id)
if [ -z "$DEVICE_ID" ]; then
  echo "錯誤：未指定設備 ID，無法繼續"
  exit 1
fi

echo "===== 開始效能測試 ====="
echo "將會運行每個測試 $TEST_COUNT 次"
echo "設備 ID: $DEVICE_ID"

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

# 初始化測試時間記錄檔案
TEST_TIMES_FILE="$PROJECT_ROOT/test_results/test_times.json"
echo '{"tests": []}' > $TEST_TIMES_FILE

# 總測試時間
TOTAL_TEST_DURATION=0

# 循環運行每個測試檔案
for test_file in "${TEST_FILES[@]}"; do
  test_name=$(basename "$test_file" .dart)
  
  # 創建測試結果目錄
  mkdir -p "test_results/ios/${test_name}"
  
  echo -e "\n===== 運行 $test_name 測試 ====="
  
  # 檢查是否有預構建的 IPA
  IPA_PATH="$PROJECT_ROOT/build/${test_name}_ipa/study_flutter_performance_test.ipa"
  if [ ! -f "$IPA_PATH" ]; then
    echo "警告：找不到 $test_name 的預構建 IPA：$IPA_PATH"
    echo "將使用默認 IPA 路徑..."
    IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
    
    if [ ! -f "$IPA_PATH" ]; then
      echo "錯誤：找不到默認 IPA 檔案：$IPA_PATH"
      echo "請先運行 './scripts/build_ipa.sh' 構建 IPA 檔案"
      continue
    fi
  fi
  
  echo "使用 IPA 檔案: $IPA_PATH"
  
  # 根據測試名稱直接匹配對應的 driver 檔案
  driver_file="${PROJECT_ROOT}/test_driver/${test_name}_driver.dart"
  
  # 檢查 driver 檔案是否存在
  if [ ! -f "$driver_file" ]; then
    echo "錯誤：找不到 $test_name 的 driver 檔案"
    echo "測試需要對應的 driver 檔案才能運行"
    continue
  fi
  
  driver_name=$(basename "$driver_file")
  echo "使用 driver 檔案: $driver_name"
  
  # 運行多次測試
  for i in $(seq 1 $TEST_COUNT); do
    echo -e "\n===== 運行 $test_name 測試 #$i ====="
    
    # 記錄測試開始時間
    START_TIME=$(date +%s)
    
    # 使用 IPA 運行測試
    fvm flutter drive \
      --driver="$driver_file" \
      --target="$test_file" \
      --profile \
      --use-application-binary "$IPA_PATH" \
      -d $DEVICE_ID
    
    # 檢查測試是否成功
    TEST_STATUS=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    DURATION_FORMATTED=$(format_duration $DURATION)
    TOTAL_TEST_DURATION=$((TOTAL_TEST_DURATION + DURATION))
    
    # 確定結果檔案的模式，從測試名稱中提取（如 efficient_list_test -> efficient_scrolling）
    result_mode=$(echo "$test_name" | sed -E 's/_list_test$//' | sed -E 's/_test$//')
    RESULT_FILE="build/${result_mode}_scrolling.timeline_summary.json"
    
    if [ $TEST_STATUS -eq 0 ] && [ -f "$RESULT_FILE" ]; then
      # 複製結果文件並添加序號
      TARGET_FILE="test_results/ios/${test_name}/${result_mode}_scrolling_$i.timeline_summary.json"
      cp "$RESULT_FILE" "$TARGET_FILE"
      
      echo "$test_name 測試 #$i 完成並保存結果"
      echo "測試時間: $DURATION_FORMATTED"
      echo "結果文件路徑: $TARGET_FILE"
      
      # 更新測試時間 JSON
      TMP_FILE=$(mktemp)
      jq ".tests += [{
        \"name\": \"$test_name\",
        \"run\": $i,
        \"total_seconds\": $DURATION,
        \"formatted\": \"$DURATION_FORMATTED\",
        \"status\": \"success\",
        \"result_file\": \"$TARGET_FILE\"
      }]" "$TEST_TIMES_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$TEST_TIMES_FILE"
    else
      echo "$test_name 測試 #$i 失敗或找不到結果檔案"
      
      # 更新測試時間 JSON（失敗）
      TMP_FILE=$(mktemp)
      jq ".tests += [{
        \"name\": \"$test_name\",
        \"run\": $i,
        \"total_seconds\": $DURATION,
        \"formatted\": \"$DURATION_FORMATTED\",
        \"status\": \"failed\",
        \"result_file\": null
      }]" "$TEST_TIMES_FILE" > "$TMP_FILE"
      mv "$TMP_FILE" "$TEST_TIMES_FILE"
    fi
    
    # 等待設備冷卻
    sleep 3
  done
done

# 更新測試總時間
TOTAL_TEST_FORMATTED=$(format_duration $TOTAL_TEST_DURATION)
TMP_FILE=$(mktemp)
jq ".total = { \"total_seconds\": $TOTAL_TEST_DURATION, \"formatted\": \"$TOTAL_TEST_FORMATTED\" }" "$TEST_TIMES_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$TEST_TIMES_FILE"

echo -e "\n===== 測試完成 ====="
echo "總計運行了 ${#TEST_FILES[@]} 個測試檔案，每個檔案 $TEST_COUNT 次測試"
echo "總測試時間: $TOTAL_TEST_FORMATTED"
echo "所有結果已保存到: test_results/ios/ 目錄"
echo "測試時間詳情已保存到: $TEST_TIMES_FILE"