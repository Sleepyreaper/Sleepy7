#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-build}"

xcodebuild \
  -project "${IOS_PROJECT}" \
  -scheme "${IOS_SCHEME}" \
  -configuration "${IOS_CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  "${ACTION}"