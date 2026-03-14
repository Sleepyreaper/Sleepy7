#!/usr/bin/env bash
set -euo pipefail

ARCHIVE_PATH="${ARCHIVE_PATH:-.build/Sleepy7.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-.build/export}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-.ci/ExportOptions.plist}"

rm -rf "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

set -x
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -allowProvisioningUpdates