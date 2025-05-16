#!/bin/bash

# 創建結果目錄
mkdir -p test_results

# 確保build目錄存在
mkdir -p build

# 要運行的測試次數
TEST_COUNT=5

echo "===== 開始效能測試 ====="
echo "將會運行每個測試 $TEST_COUNT 次"

# 先運行優化版本的測試
for i in $(seq 1 $TEST_COUNT)
do
  echo -e "\n===== 運行優化版本測試 #$i ====="
  
  # 使用你的設備ID (可以通過 'flutter devices' 獲取)
  flutter drive \
    --driver=test_driver/efficient_driver.dart \
    --target=integration_test/efficient_list_test.dart \
    --profile
  
  # 檢查測試是否成功
  if [ $? -eq 0 ]; then
    # 複製結果文件並添加序號
    cp build/efficient_scrolling.timeline_summary.json test_results/efficient_scrolling_$i.timeline_summary.json
    echo "優化版本測試 #$i 完成並保存結果"
  else
    echo "優化版本測試 #$i 失敗"
  fi
  
  # 等待設備冷卻
  sleep 3
done

# 再運行低效能版本的測試
for i in $(seq 1 $TEST_COUNT)
do
  echo -e "\n===== 運行低效能版本測試 #$i ====="
  
  # 使用你的設備ID
  flutter drive \
    --driver=test_driver/inefficient_driver.dart \
    --target=integration_test/inefficient_list_test.dart \
    --profile
  
  # 檢查測試是否成功
  if [ $? -eq 0 ]; then
    # 複製結果文件並添加序號
    cp build/inefficient_scrolling.timeline_summary.json test_results/inefficient_scrolling_$i.timeline_summary.json
    echo "低效能版本測試 #$i 完成並保存結果"
  else
    echo "低效能版本測試 #$i 失敗"
  fi
  
  # 等待設備冷卻
  sleep 3
done

echo -e "\n===== 生成比較報告 ====="
# 複製最新的測試結果用於生成報告
cp test_results/efficient_scrolling_$TEST_COUNT.timeline_summary.json build/efficient_scrolling.timeline_summary.json
cp test_results/inefficient_scrolling_$TEST_COUNT.timeline_summary.json build/inefficient_scrolling.timeline_summary.json


echo -e "\n===== 測試完成 ====="
echo "所有結果已保存到 test_results/ 目錄"