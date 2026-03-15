#!/usr/bin/env bash
set -euo pipefail

SCHEME="Sleepy7"
PROJECT="Sleepy7.xcodeproj"
DESTINATION="${1:-platform=iOS Simulator,name=iPhone 15 Pro}"
DERIVED_DATA_PATH="${PWD}/build/DerivedData"
SCREENSHOT_DIR="${PWD}/build/screenshots"

mkdir -p "${SCREENSHOT_DIR}"

echo "▶ Cleaning previous artifacts..."
rm -rf "${DERIVED_DATA_PATH}"

echo "▶ Booting simulator..."
xcrun simctl bootstatus booted || true

echo "▶ Building app for screenshots..."
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  clean build

APP_PATH=$(find "${DERIVED_DATA_PATH}" -type d -name "${SCHEME}.app" | head -n 1)

if [[ -z "${APP_PATH}" ]]; then
  echo "✖ Could not locate built app."
  exit 1
fi

echo "▶ Installing app..."
xcrun simctl install booted "${APP_PATH}"

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "${APP_PATH}/Info.plist")

echo "▶ Launching app..."
xcrun simctl launch booted "${BUNDLE_ID}" || true
sleep 3

capture() {
  local name="$1"
  echo "▶ Capturing ${name}"
  xcrun simctl io booted screenshot "${SCREENSHOT_DIR}/${name}.png"
  sleep 1
}

capture "01_main_menu"
capture "02_gameplay"
capture "03_stats"
capture "04_rules"
capture "05_store"

echo "✔ Screenshots saved to ${SCREENSHOT_DIR}"
echo "Tip: drive deterministic UI states with launch arguments or UI tests for true App Store Connect-ready previews."