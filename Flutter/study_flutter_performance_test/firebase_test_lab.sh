#!/bin/bash
set -e  # 出現錯誤時立即退出

# 添加日誌函數
log_info() {
  echo "INFO: $1"
}

log_error() {
  echo "ERROR: $1"
}

log_debug() {
  echo "DEBUG: $1"
}

output="../build/ios_integ"
product="build/ios_integ/Build/Products"

log_info "開始執行腳本"
log_debug "當前工作目錄: $(pwd)"

log_info "清理 Flutter 項目"
fvm flutter clean

log_info "開始構建 iOS 集成測試"
# Pass --simulator if building for the simulator.
fvm flutter build ios integration_test/inefficient_list_test.dart --release
log_debug "Flutter 構建完成，輸出目錄: $output"

log_debug "開始 xcodebuild 階段，切換到 iOS 目錄"
log_debug "當前工作目錄: $(pwd)"
if [ ! -d "ios" ]; then
  log_error "ios 目錄不存在!"
  exit 1
fi

pushd ios
log_debug "已切換到 iOS 目錄: $(pwd)"

log_info "使用 xcodebuild 構建測試"
xcodebuild build-for-testing \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -xcconfig Flutter/Release.xcconfig \
  -configuration Release \
  -derivedDataPath \
  $output -sdk iphoneos
log_debug "xcodebuild 構建完成"

popd
log_debug "返回上層目錄: $(pwd)"

# 檢查產品目錄是否存在
if [ ! -d "$product" ]; then
  log_error "產品目錄不存在: $product"
  log_debug "嘗試查找實際生成的目錄..."
  find "../build" -type d -name "Products" -print
  exit 1
fi

log_info "開始打包測試文件"
pushd $product
log_debug "已切換到產品目錄: $(pwd)"

# 檢查 Release-iphoneos 目錄
if [ ! -d "Release-iphoneos" ]; then
  log_error "Release-iphoneos 目錄不存在!"
  log_debug "目錄內容:"
  ls -la
fi

# 檢查 xctestrun 文件
XCTESTRUN_FILES=$(find . -name "Runner_*.xctestrun")
if [ -z "$XCTESTRUN_FILES" ]; then
  log_error "找不到 xctestrun 文件!"
else
  log_debug "找到以下 xctestrun 文件:"
  echo "$XCTESTRUN_FILES"
fi

log_info "創建 zip 文件"
find . -name "Runner_*.xctestrun" -exec zip -r --must-match "ios_tests.zip" "Release-iphoneos" {} +
log_debug "zip 命令完成"

popd
log_info "腳本執行完成"