#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 創建報告目錄
mkdir -p test_results
mkdir -p test_results/ios/efficient_scrolling
mkdir -p test_results/ios/inefficient_scrolling

# 時間格式化函數 (兼容 macOS)
format_duration() {
  local seconds=$1
  local hours=$((seconds / 3600))
  local minutes=$(((seconds % 3600) / 60))
  local secs=$((seconds % 60))
  printf "%02d:%02d:%02d" $hours $minutes $secs
}

echo "===== Flutter 效能測試全流程 ====="
echo "1. 構建IPA檔案"
echo "2. 運行效能測試"
echo "3. 生成測試報告"

# 確保腳本有執行權限
chmod +x ./scripts/build_ipa.sh
chmod +x ./scripts/run_performance_tests.sh

# 初始化報告檔案路徑
REPORT_FILE="$PROJECT_ROOT/test_results/performance_report.json"

# 步驟 1: 構建IPA檔案
echo -e "\n===== 步驟 1: 構建IPA檔案 ====="
START_BUILD_TIME=$(date +%s)
./scripts/build_ipa.sh

# 檢查構建是否成功
BUILD_STATUS=$?
END_BUILD_TIME=$(date +%s)
BUILD_DURATION=$((END_BUILD_TIME - START_BUILD_TIME))
BUILD_DURATION_FORMATTED=$(format_duration $BUILD_DURATION)

# 讀取構建時間
EFFICIENT_BUILD="{}"
INEFFICIENT_BUILD="{}"
if [ -f "$PROJECT_ROOT/test_results/build_times.json" ]; then
  EFFICIENT_BUILD=$(jq -c '.efficient_build' "$PROJECT_ROOT/test_results/build_times.json")
  INEFFICIENT_BUILD=$(jq -c '.inefficient_build' "$PROJECT_ROOT/test_results/build_times.json")
fi

# 如果構建失敗，則生成報告並退出
if [ $BUILD_STATUS -ne 0 ]; then
  echo "IPA構建失敗，退出測試"
  BUILD_STATUS_STR="failed"
  
  # 創建失敗的報告
  cat > $REPORT_FILE << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "test_cases": {
    "efficient": {
      "build_time": $EFFICIENT_BUILD,
      "files": []
    },
    "inefficient": {
      "build_time": $INEFFICIENT_BUILD,
      "files": []
    }
  },
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
./scripts/run_performance_tests.sh

# 檢查測試是否成功
TEST_STATUS=$?
END_TEST_TIME=$(date +%s)
TEST_DURATION=$((END_TEST_TIME - START_TEST_TIME))
TEST_DURATION_FORMATTED=$(format_duration $TEST_DURATION)

# 步驟 3: 生成測試報告
echo -e "\n===== 步驟 3: 生成測試報告 ====="

# 查找測試結果目錄下的所有 timeline_summary 檔案
echo "搜尋 timeline_summary 檔案..."
efficient_files_json="[]"
inefficient_files_json="[]"

# 高效版本的測試檔案
EFFICIENT_FILES=()
for file in $PROJECT_ROOT/test_results/ios/efficient_scrolling/efficient_scrolling_*.timeline_summary.json; do
  if [ -f "$file" ]; then
    EFFICIENT_FILES+=("$file")
  fi
done

if [ ${#EFFICIENT_FILES[@]} -gt 0 ]; then
  efficient_files_json=$(printf '"%s",' "${EFFICIENT_FILES[@]}" | sed 's/,$//')
  efficient_files_json="[$efficient_files_json]"
fi

# 低效版本的測試檔案
INEFFICIENT_FILES=()
for file in $PROJECT_ROOT/test_results/ios/inefficient_scrolling/inefficient_scrolling_*.timeline_summary.json; do
  if [ -f "$file" ]; then
    INEFFICIENT_FILES+=("$file")
  fi
done

if [ ${#INEFFICIENT_FILES[@]} -gt 0 ]; then
  inefficient_files_json=$(printf '"%s",' "${INEFFICIENT_FILES[@]}" | sed 's/,$//')
  inefficient_files_json="[$inefficient_files_json]"
fi

# 更新總結
TOTAL_DURATION=$((BUILD_DURATION + TEST_DURATION))
TOTAL_DURATION_FORMATTED=$(format_duration $TOTAL_DURATION)
TEST_STATUS_STR=$([ $TEST_STATUS -eq 0 ] && echo "success" || echo "failed")

echo "生成最終報告..."
# 創建完整的JSON報告
cat > $REPORT_FILE << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "test_cases": {
    "efficient": {
      "build_time": $EFFICIENT_BUILD,
      "files": $efficient_files_json
    },
    "inefficient": {
      "build_time": $INEFFICIENT_BUILD,
      "files": $inefficient_files_json
    }
  },
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

echo -e "\n===== Timeline Summary 檔案路徑 ====="
echo "找到 ${#EFFICIENT_FILES[@]} 個高效版本測試檔案"
for file in "${EFFICIENT_FILES[@]}"; do
  echo "- $file"
done

echo -e "\n找到 ${#INEFFICIENT_FILES[@]} 個低效版本測試檔案"
for file in "${INEFFICIENT_FILES[@]}"; do
  echo "- $file"
done

echo -e "\n===== 全流程完成 ====="
echo "恭喜！構建和測試流程已全部完成"
echo "詳細報告已保存到: $REPORT_FILE"
echo "可以使用以下命令查看報告摘要:"
echo "jq . $REPORT_FILE | less"
echo -e "\n查看高效版本測試結果檔案路徑:"
echo "jq '.test_cases.efficient.files' $REPORT_FILE"
echo -e "\n查看低效版本測試結果檔案路徑:"
echo "jq '.test_cases.inefficient.files' $REPORT_FILE" 