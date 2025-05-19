#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 載入環境變數配置
ENV_FILE="$(cd "$(dirname "$0")" && pwd)/.env"
if [ -f "$ENV_FILE" ]; then
  echo "載入 scripts/.env 配置文件"
  # 讀取環境變數
  while IFS='=' read -r key value || [ -n "$key" ]; do
    # 跳過註釋和空行
    [[ $key =~ ^#.*$ || -z $key ]] && continue
    # 設定環境變數
    export "$key"="$value"
    echo "設定環境變數: $key"
  done < "$ENV_FILE"
else
  echo "錯誤：找不到 scripts/.env 配置文件"
  echo "請複製 scripts/.env.template 文件為 scripts/.env 並填入正確的設備 ID"
  exit 1
fi

# 創建結果目錄
mkdir -p test_results
mkdir -p test_results/ios
mkdir -p test_results/android

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

# 初始化平台變數（不預設值）
PLATFORM=""

# 解析命令行參數
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --platform)
      PLATFORM="$2"
      shift
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# 驗證平台參數
if [[ "$PLATFORM" != "ios" && "$PLATFORM" != "android" ]]; then
  echo "錯誤：必須指定平台為 'ios' 或 'android'"
  echo "使用方式：$0 --platform ios|android"
  exit 1
fi

# 獲取 iOS 設備 ID
get_ios_device_id() {
  # 檢查環境變數
  if [ -n "$IOS_DEVICE_ID" ]; then
    echo "使用 scripts/.env 中的 iOS 設備 ID: $IOS_DEVICE_ID"
    echo "$IOS_DEVICE_ID"
    return
  fi
  
  # 若環境變數未設定，顯示錯誤
  echo "錯誤：未在 scripts/.env 文件中設定 IOS_DEVICE_ID"
  echo "請在 scripts/.env 文件中設定正確的 iOS 設備 ID"
  exit 1
}

# 獲取 Android 設備 ID
get_android_device_id() {
  # 檢查環境變數
  if [ -n "$ANDROID_DEVICE_ID" ]; then
    echo "使用 scripts/.env 中的 Android 設備 ID: $ANDROID_DEVICE_ID"
    echo "$ANDROID_DEVICE_ID"
    return
  fi
  
  # 若環境變數未設定，顯示錯誤
  echo "錯誤：未在 scripts/.env 文件中設定 ANDROID_DEVICE_ID"
  echo "請在 scripts/.env 文件中設定正確的 Android 設備 ID"
  exit 1
}

# 根據選擇的平台獲取設備 ID
if [ "$PLATFORM" == "ios" ]; then
  DEVICE_ID=$(get_ios_device_id)
else
  DEVICE_ID=$(get_android_device_id)
fi

echo "===== 開始效能測試 ====="
echo "將會運行每個測試 $TEST_COUNT 次"
echo "平台: $PLATFORM"
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

# 總測試時間
TOTAL_TEST_DURATION=0

# 循環運行每個測試檔案
for test_file in "${TEST_FILES[@]}"; do
  test_name=$(basename "$test_file" .dart)
  
  # 創建測試結果目錄
  mkdir -p "test_results/$PLATFORM/${test_name}"
  
  echo -e "\n===== 運行 $test_name 測試 ====="
  
  # 檢查是否有預構建的二進制檔案
  if [ "$PLATFORM" == "ios" ]; then
    BINARY_PATH="$PROJECT_ROOT/build/${test_name}_ipa/study_flutter_performance_test.ipa"
    if [ ! -f "$BINARY_PATH" ]; then
      echo "警告：找不到 $test_name 的預構建 IPA：$BINARY_PATH"
      echo "將使用默認 IPA 路徑..."
      BINARY_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
      
      if [ ! -f "$BINARY_PATH" ]; then
        echo "錯誤：找不到默認 IPA 檔案：$BINARY_PATH"
        echo "請先運行 './scripts/build_ipa.sh' 構建 IPA 檔案"
        continue
      fi
    fi
  else
    BINARY_PATH="$PROJECT_ROOT/build/${test_name}_apk/app-profile.apk"
    if [ ! -f "$BINARY_PATH" ]; then
      echo "警告：找不到 $test_name 的預構建 APK：$BINARY_PATH"
      echo "將使用默認 APK 路徑..."
      BINARY_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-profile.apk"
      
      if [ ! -f "$BINARY_PATH" ]; then
        echo "錯誤：找不到默認 APK 檔案：$BINARY_PATH"
        echo "請先運行 './scripts/build_apk.sh' 構建 APK 檔案"
        continue
      fi
    fi
  fi
  
  echo "使用二進制檔案: $BINARY_PATH"
  
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
    
    # 使用二進制檔案運行測試
    fvm flutter drive \
      --driver="$driver_file" \
      --target="$test_file" \
      --profile \
      --use-application-binary "$BINARY_PATH" \
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
      TARGET_FILE="test_results/$PLATFORM/${test_name}/${result_mode}_scrolling_$i.timeline_summary.json"
      cp "$RESULT_FILE" "$TARGET_FILE"
      
      echo "$test_name 測試 #$i 完成並保存結果"
      echo "測試時間: $DURATION_FORMATTED"
      echo "結果文件路徑: $TARGET_FILE"
    else
      echo "$test_name 測試 #$i 失敗或找不到結果檔案"
    fi
    
    # 等待設備冷卻
    sleep 3
  done
done

TOTAL_TEST_FORMATTED=$(format_duration $TOTAL_TEST_DURATION)

echo -e "\n===== 測試完成 ====="
echo "總計運行了 ${#TEST_FILES[@]} 個測試檔案，每個檔案 $TEST_COUNT 次測試"
echo "總測試時間: $TOTAL_TEST_FORMATTED"
echo "所有結果已保存到: test_results/$PLATFORM/ 目錄"