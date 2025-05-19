#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 創建結果目錄
mkdir -p test_results
mkdir -p test_results/ios/efficient_scrolling
mkdir -p test_results/ios/inefficient_scrolling

# 確保build目錄存在
mkdir -p build

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

# 設備ID (可以通過 'flutter devices' 或 'xcrun xctrace list devices' 獲取)
DEVICE_ID="00008120-000E71AA3E90C01E"

echo "===== 開始效能測試 ====="
echo "將會運行每個測試 $TEST_COUNT 次"
echo "設備ID: $DEVICE_ID"

IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"

# 檢查IPA檔案是否存在
if [ ! -f "$IPA_PATH" ]; then
  echo "錯誤：IPA檔案不存在: $IPA_PATH"
  echo "請先運行 './scripts/build_ipa.sh' 構建IPA檔案"
  exit 1
fi

echo "使用IPA檔案: $IPA_PATH"

# 初始化測試時間記錄
EFFICIENT_TOTAL_TIME=0
INEFFICIENT_TOTAL_TIME=0

# 運行優化版本的測試
for i in $(seq 1 $TEST_COUNT)
do
  echo -e "\n===== 運行優化版本測試 #$i ====="
  
  # 記錄測試開始時間
  START_TIME=$(date +%s)
  
  # 使用預構建的IPA運行測試
  fvm flutter drive \
    --driver=test_driver/efficient_driver.dart \
    --target=integration_test/efficient_list_test.dart \
    --profile \
    --use-application-binary "$IPA_PATH" \
    -d $DEVICE_ID
  
  # 檢查測試是否成功
  TEST_STATUS=$?
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  DURATION_FORMATTED=$(format_duration $DURATION)
  EFFICIENT_TOTAL_TIME=$((EFFICIENT_TOTAL_TIME + DURATION))
  
  if [ $TEST_STATUS -eq 0 ]; then
    # 複製結果文件並添加序號
    cp build/efficient_scrolling.timeline_summary.json test_results/ios/efficient_scrolling/efficient_scrolling_$i.timeline_summary.json
    SUMMARY_PATH="$PROJECT_ROOT/test_results/ios/efficient_scrolling/efficient_scrolling_$i.timeline_summary.json"
    
    echo "優化版本測試 #$i 完成並保存結果"
    echo "測試時間: $DURATION_FORMATTED"
    echo "結果文件路徑: $SUMMARY_PATH"
  else
    echo "優化版本測試 #$i 失敗"
  fi
  
  # 等待設備冷卻
  sleep 3
done

# 運行低效能版本的測試
for i in $(seq 1 $TEST_COUNT)
do
  echo -e "\n===== 運行低效能版本測試 #$i ====="
  
  # 記錄測試開始時間
  START_TIME=$(date +%s)
  
  # 使用預構建的IPA運行測試
  fvm flutter drive \
    --driver=test_driver/inefficient_driver.dart \
    --target=integration_test/inefficient_list_test.dart \
    --profile \
    --use-application-binary "$IPA_PATH" \
    -d $DEVICE_ID
  
  # 檢查測試是否成功
  TEST_STATUS=$?
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  DURATION_FORMATTED=$(format_duration $DURATION)
  INEFFICIENT_TOTAL_TIME=$((INEFFICIENT_TOTAL_TIME + DURATION))
  
  if [ $TEST_STATUS -eq 0 ]; then
    # 複製結果文件並添加序號
    cp build/inefficient_scrolling.timeline_summary.json test_results/ios/inefficient_scrolling/inefficient_scrolling_$i.timeline_summary.json
    SUMMARY_PATH="$PROJECT_ROOT/test_results/ios/inefficient_scrolling/inefficient_scrolling_$i.timeline_summary.json"
    
    echo "低效能版本測試 #$i 完成並保存結果"
    echo "測試時間: $DURATION_FORMATTED"
    echo "結果文件路徑: $SUMMARY_PATH"
  else
    echo "低效能版本測試 #$i 失敗"
  fi
  
  # 等待設備冷卻
  sleep 3
done

# 更新測試總時間
TOTAL_TEST_TIME=$((EFFICIENT_TOTAL_TIME + INEFFICIENT_TOTAL_TIME))
EFFICIENT_TOTAL_FORMATTED=$(format_duration $EFFICIENT_TOTAL_TIME)
INEFFICIENT_TOTAL_FORMATTED=$(format_duration $INEFFICIENT_TOTAL_TIME)
TOTAL_TEST_FORMATTED=$(format_duration $TOTAL_TEST_TIME)

echo -e "\n===== 生成比較報告 ====="
# 複製最新的測試結果用於生成報告
cp test_results/ios/efficient_scrolling/efficient_scrolling_$TEST_COUNT.timeline_summary.json build/efficient_scrolling.timeline_summary.json
cp test_results/ios/inefficient_scrolling/inefficient_scrolling_$TEST_COUNT.timeline_summary.json build/inefficient_scrolling.timeline_summary.json

echo -e "\n===== 測試完成 ====="
echo "測試時間總結:"
echo "- 高效版本總計: $EFFICIENT_TOTAL_FORMATTED"
echo "- 低效版本總計: $INEFFICIENT_TOTAL_FORMATTED"
echo "- 總計: $TOTAL_TEST_FORMATTED"

echo "所有結果已保存到: test_results/ios/ 目錄"