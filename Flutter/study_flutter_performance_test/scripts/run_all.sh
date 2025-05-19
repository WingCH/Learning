#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "===== Flutter 效能測試全流程 ====="
echo "1. 構建IPA檔案"
echo "2. 運行效能測試"

# 確保腳本有執行權限
chmod +x ./scripts/build_ipa.sh
chmod +x ./scripts/run_performance_tests.sh

# 步驟 1: 構建IPA檔案
echo -e "\n===== 步驟 1: 構建IPA檔案 ====="
./scripts/build_ipa.sh

# 檢查構建是否成功
if [ $? -ne 0 ]; then
  echo "IPA構建失敗，退出測試"
  exit 1
fi

# 步驟 2: 運行效能測試
echo -e "\n===== 步驟 2: 運行效能測試 ====="
./scripts/run_performance_tests.sh

# 檢查測試是否成功
if [ $? -ne 0 ]; then
  echo "效能測試運行失敗"
  exit 1
fi

echo -e "\n===== 全流程完成 ====="
echo "恭喜！構建和測試流程已全部完成" 