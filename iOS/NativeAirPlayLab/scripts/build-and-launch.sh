#!/usr/bin/env bash
set -euo pipefail

SCHEME="NativeAirPlayLab"
PROJECT="NativeAirPlayLab.xcodeproj"
APP_BUNDLE_ID="com.wingchan.NativeAirPlayLab"
DESTINATION_ID="${DESTINATION_ID:-}"
DESTINATION_NAME="${DESTINATION_NAME:-iPhone 16}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$(pwd)/.derivedData/run}"

if [[ -z "$DESTINATION_ID" ]]; then
  while IFS= read -r device_line; do
    device_name="$(sed -E 's/^[[:space:]]*//; s/[[:space:]]+\([0-9A-F-]+\).*$//' <<<"$device_line")"
    device_id="$(sed -nE 's/.*\(([0-9A-F-]+)\).*/\1/p' <<<"$device_line")"
    if [[ "$device_name" == "$DESTINATION_NAME" && -n "$device_id" ]]; then
      DESTINATION_ID="$device_id"
      break
    fi
  done < <(xcrun simctl list devices available)
fi

if [[ -z "$DESTINATION_ID" ]]; then
  echo "No available simulator matched DESTINATION_NAME=$DESTINATION_NAME" >&2
  echo "Set DESTINATION_ID to an available simulator UDID." >&2
  exit 1
fi

xcrun simctl boot "$DESTINATION_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DESTINATION_ID" -b

xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$DESTINATION_ID" \
  -derivedDataPath "$DERIVED_DATA_PATH"

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/$SCHEME.app"
xcrun simctl install "$DESTINATION_ID" "$APP_PATH"
xcrun simctl launch "$DESTINATION_ID" "$APP_BUNDLE_ID"
