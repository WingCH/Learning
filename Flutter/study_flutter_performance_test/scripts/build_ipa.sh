#!/bin/bash

# 獲取專案根目錄
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 確保build目錄存在
mkdir -p build

echo "===== 開始構建IPA檔案 ====="

# 構建高效版本的IPA
echo -e "\n===== 預先構建高效版本IPA ====="
fvm flutter build ipa \
  --target=integration_test/efficient_list_test.dart \
  --profile \
  --export-method development

if [ $? -ne 0 ]; then
  echo "構建高效版本IPA失敗，退出"
  exit 1
fi

EFFICIENT_IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
echo "高效版本IPA已構建: $EFFICIENT_IPA_PATH"

# 備份高效版本IPA
mkdir -p build/efficient_ipa
cp -r build/ios/ipa/* build/efficient_ipa/
echo "高效版本IPA已備份到: build/efficient_ipa/"

# 構建低效版本的IPA
echo -e "\n===== 預先構建低效版本IPA ====="
fvm flutter build ipa \
  --target=integration_test/inefficient_list_test.dart \
  --profile \
  --export-method development

if [ $? -ne 0 ]; then
  echo "構建低效版本IPA失敗，退出"
  exit 1
fi

INEFFICIENT_IPA_PATH="$PROJECT_ROOT/build/ios/ipa/study_flutter_performance_test.ipa"
echo "低效版本IPA已構建: $INEFFICIENT_IPA_PATH"

# 備份低效版本IPA
mkdir -p build/inefficient_ipa
cp -r build/ios/ipa/* build/inefficient_ipa/
echo "低效版本IPA已備份到: build/inefficient_ipa/"

echo -e "\n===== IPA構建完成 ====="
echo "高效版本IPA位置: build/efficient_ipa/study_flutter_performance_test.ipa"
echo "低效版本IPA位置: $INEFFICIENT_IPA_PATH (當前IPA檔案)"
echo "可以運行 './scripts/run_performance_tests.sh' 開始測試" 