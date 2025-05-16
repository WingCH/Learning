#!/bin/bash

# 創建結果目錄
mkdir -p test_results

# 運行10次測試
for i in {1..10}
do
  echo "運行測試 #$i"
  
  # 使用模擬器ID直接運行測試
  flutter drive --driver=test_driver/comparison_driver.dart --target=integration_test/comparison_test.dart -d "iPhone 16 Pro"
  
  # 檢查測試是否成功
  if [ $? -eq 0 ]; then
    # 複製結果文件並添加序號
    cp build/inefficient_scrolling.timeline_summary.json test_results/inefficient_scrolling_$i.timeline_summary.json
    cp build/efficient_scrolling.timeline_summary.json test_results/efficient_scrolling_$i.timeline_summary.json
    cp build/performance_comparison_report.json test_results/performance_comparison_report_$i.json
    
    echo "測試 #$i 完成並保存結果"
  else
    echo "測試 #$i 失敗"
  fi
  
  # 等待幾秒，確保設備冷卻和準備好
  sleep 5
done

# 創建分析結果摘要文件
echo "總結所有測試結果..."
echo "{" > test_results/summary.json
echo "  \"tests\": [" >> test_results/summary.json

for i in {1..10}
do
  if [ -f "test_results/performance_comparison_report_$i.json" ]; then
    # 提取數據並添加到摘要中
    echo "  {" >> test_results/summary.json
    echo "    \"run\": $i," >> test_results/summary.json
    echo "    \"data\": $(cat test_results/performance_comparison_report_$i.json)" >> test_results/summary.json
    
    # 最後一個元素不添加逗號
    if [ $i -eq 10 ]; then
      echo "  }" >> test_results/summary.json
    else
      echo "  }," >> test_results/summary.json
    fi
  fi
done

echo "  ]" >> test_results/summary.json
echo "}" >> test_results/summary.json

echo "完成! 結果保存在 test_results/ 目錄" 