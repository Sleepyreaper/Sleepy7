#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 <build-for-testing|test-without-building>"
  exit 1
fi

SCHEME="${IOS_SCHEME:-Sleepy7}"
PROJECT="${IOS_PROJECT:-Sleepy7.xcodeproj}"
CONFIGURATION="${IOS_CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-.build/DerivedData}"
RESULT_BUNDLE_PATH="${RESULT_BUNDLE_PATH:-.build/TestResults.xcresult}"
DESTINATION="${IOS_DESTINATION:-platform=iOS Simulator,name=iPhone 15,OS=17.5}"

COMMON_ARGS=(
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  -derivedDataPath "$DERIVED_DATA_PATH"
  -resultBundlePath "$RESULT_BUNDLE_PATH"
  -destination "$DESTINATION"
  CODE_SIGNING_ALLOWED=NO
)

if [[ -n "${IOS_WORKSPACE:-}" ]]; then
  PROJECT_ARGS=(-workspace "${IOS_WORKSPACE}")
else
  PROJECT_ARGS=(-project "${PROJECT}")
fi

set -x
xcodebuild \
  "${PROJECT_ARGS[@]}" \
  "${COMMON_ARGS[@]}" \
  "$ACTION"