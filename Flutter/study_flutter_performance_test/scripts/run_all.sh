#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

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

# 創建報告目錄
mkdir -p test_results
mkdir -p test_results/$PLATFORM

# 時間格式化函數 (兼容 macOS)
format_duration() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $secs
}

echo "===== Flutter 效能測試全流程 ====="
echo "平台: $PLATFORM"
echo "1. 構建測試二進制檔案"
echo "2. 運行效能測試"
echo "3. 生成測試報告"

# 確保腳本有執行權限
chmod +x ./scripts/build_ipa.sh
chmod +x ./scripts/build_apk.sh
chmod +x ./scripts/run_performance_tests.sh

# 初始化報告檔案路徑
REPORT_FILE="$PROJECT_ROOT/test_results/performance_report.json"

# 步驟 1: 構建二進制檔案
echo -e "\n===== 步驟 1: 構建二進制檔案 ====="
START_BUILD_TIME=$(date +%s)

# 根據平台選擇構建命令
if [ "$PLATFORM" == "ios" ]; then
  ./scripts/build_ipa.sh
else
  ./scripts/build_apk.sh
fi

# 檢查構建是否成功
BUILD_STATUS=$?
END_BUILD_TIME=$(date +%s)
BUILD_DURATION=$((END_BUILD_TIME - START_BUILD_TIME))
BUILD_DURATION_FORMATTED=$(format_duration $BUILD_DURATION)

# 讀取構建時間
BUILD_TIMES="{}"
if [ -f "$PROJECT_ROOT/test_results/build_times.json" ]; then
  BUILD_TIMES=$(cat "$PROJECT_ROOT/test_results/build_times.json")
fi

# 如果構建失敗，則生成報告並退出
if [ $BUILD_STATUS -ne 0 ]; then
  echo "二進制檔案構建失敗，退出測試"
  BUILD_STATUS_STR="failed"
  
  # 創建失敗的報告
  cat > $REPORT_FILE << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platform": "$PLATFORM",
  "build": $BUILD_TIMES,
  "tests": [],
  "summary": {
    "build_time": {
      "total_seconds": $BUILD_DURATION,
      "formatted": "$BUILD_DURATION_FORMATTED"
    },
    "build_status": "failed",
    "completed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF

  echo "詳細報告已保存到: $REPORT_FILE"
  exit 1
fi

BUILD_STATUS_STR="success"

# 步驟 2: 運行效能測試
echo -e "\n===== 步驟 2: 運行效能測試 ====="
START_TEST_TIME=$(date +%s)
# 將平台參數傳遞給測試腳本
./scripts/run_performance_tests.sh --platform $PLATFORM

# 檢查測試是否成功
TEST_STATUS=$?
END_TEST_TIME=$(date +%s)
TEST_DURATION=$((END_TEST_TIME - START_TEST_TIME))
TEST_DURATION_FORMATTED=$(format_duration $TEST_DURATION)

# 步驟 3: 生成測試報告
echo -e "\n===== 步驟 3: 生成測試報告 ====="

# 查找測試結果目錄的所有測試目錄
echo "搜尋測試結果目錄..."
TEST_DIRECTORIES=()
for dir in "$PROJECT_ROOT/test_results/$PLATFORM"/*; do
  if [ -d "$dir" ]; then
    TEST_DIRECTORIES+=("$(basename "$dir")")
  fi
done

echo "找到 ${#TEST_DIRECTORIES[@]} 個測試目錄："
for dir in "${TEST_DIRECTORIES[@]}"; do
  echo "- $dir"
  
  # 查找每個測試目錄中的所有 timeline_summary 檔案
  RESULT_FILES=()
  for file in "$PROJECT_ROOT/test_results/$PLATFORM/$dir"/*.timeline_summary.json; do
    if [ -f "$file" ]; then
      RESULT_FILES+=("$(basename "$file")")
    fi
  done
  
  echo "  找到 ${#RESULT_FILES[@]} 個結果檔案"
done

# 更新總結
TOTAL_DURATION=$((BUILD_DURATION + TEST_DURATION))
TOTAL_DURATION_FORMATTED=$(format_duration $TOTAL_DURATION)
TEST_STATUS_STR=$([ $TEST_STATUS -eq 0 ] && echo "success" || echo "failed")

echo "生成最終報告..."
# 創建完整的JSON報告
cat > $REPORT_FILE << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "platform": "$PLATFORM",
  "build": $BUILD_TIMES,
  "summary": {
    "build_time": {
      "total_seconds": $BUILD_DURATION,
      "formatted": "$BUILD_DURATION_FORMATTED"
    },
    "build_status": "$BUILD_STATUS_STR",
    "test_time": {
      "total_seconds": $TEST_DURATION,
      "formatted": "$TEST_DURATION_FORMATTED"
    },
    "test_status": "$TEST_STATUS_STR",
    "total_duration": {
      "total_seconds": $TOTAL_DURATION,
      "formatted": "$TOTAL_DURATION_FORMATTED"
    },
    "completed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  }
}
EOF

# 如果測試失敗，顯示警告但繼續生成報告
if [ $TEST_STATUS -ne 0 ]; then
  echo "警告：效能測試運行出現錯誤，但報告仍然已經生成"
fi

echo -e "\n===== 測試結果摘要 ====="
echo "總共找到 ${#TEST_DIRECTORIES[@]} 個測試目錄"
for dir in "${TEST_DIRECTORIES[@]}"; do
  echo "- $dir"
done

echo -e "\n===== 全流程完成 ====="
echo "恭喜！構建和測試流程已全部完成"
echo "詳細報告已保存到: $REPORT_FILE"
echo "可以使用以下命令查看報告摘要:"
echo "jq . $REPORT_FILE | less"
echo -e "\n查看構建詳情:"
echo "jq '.build' $REPORT_FILE | less" 