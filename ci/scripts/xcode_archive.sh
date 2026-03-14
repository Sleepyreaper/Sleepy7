#!/usr/bin/env bash
set -euo pipefail

SCHEME="${IOS_SCHEME:-Sleepy7}"
PROJECT="${IOS_PROJECT:-Sleepy7.xcodeproj}"
CONFIGURATION="${IOS_CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-.build/DerivedData}"
ARCHIVE_PATH="${ARCHIVE_PATH:-.build/Sleepy7.xcarchive}"

if [[ -n "${IOS_WORKSPACE:-}" ]]; then
  PROJECT_ARGS=(-workspace "${IOS_WORKSPACE}")
else
  PROJECT_ARGS=(-project "${PROJECT}")
fi

EXTRA_ARGS=()
if [[ -n "${IOS_TEAM_ID:-}" ]]; then
  EXTRA_ARGS+=("DEVELOPMENT_TEAM=${IOS_TEAM_ID}")
fi

set -x
xcodebuild \
  "${PROJECT_ARGS[@]}" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -archivePath "$ARCHIVE_PATH" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  "${EXTRA_ARGS[@]}" \
  clean archive