#!/bin/zsh

# 模擬器 UUID (iPhone 16 Pro Max 18.3)
DEVICE_UUID="5D726F89-0718-4F07-8B95-07BADE7D84DD"
APP_PATH="/Users/wingchan/Library/Developer/Xcode/DerivedData/study_xctrace-ftbqhyxlxrpvuzegajvvengwomvk/Build/Products/Debug-iphonesimulator/study_xctrace.app"
BUNDLE_ID="com.wingch.study-xctrace"

# 確保模擬器啟動
BOOT_STATUS=$(xcrun simctl list devices | grep $DEVICE_UUID | grep -v Booted)
if [ -n "$BOOT_STATUS" ]; then
  echo "啟動模擬器..."
  xcrun simctl boot $DEVICE_UUID
  sleep 5
fi

# 安裝應用程式
echo "安裝應用程式..."
xcrun simctl install $DEVICE_UUID $APP_PATH

# 啟動應用程式
echo "啟動應用程式..."
PROCESS_ID=$(xcrun simctl launch $DEVICE_UUID $BUNDLE_ID | awk '{print $2}')

if [ -z "$PROCESS_ID" ]; then
  echo "錯誤: 無法獲取程序 ID"
  exit 1
fi

echo "應用程式進程 ID: $PROCESS_ID"

# 確保應用程式完全啟動
sleep 2

# 使用進程 ID 進行 xctrace 分析
echo "啟動 xctrace 分析..."
xcrun xctrace record --device $DEVICE_UUID --template "Time Profiler" --attach $PROCESS_ID

# 如果使用進程 ID 失敗，可以嘗試使用 bundle ID
if [ $? -ne 0 ]; then
  echo "嘗試使用 bundle ID 進行分析..."
  xcrun xctrace record --device $DEVICE_UUID --template "Time Profiler" --attach $BUNDLE_ID
fi