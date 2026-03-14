#!/usr/bin/env bash
set -euo pipefail

EXPORT_PATH="${EXPORT_PATH:-.build/export}"
ISSUER_ID="${APP_STORE_CONNECT_ISSUER_ID:-}"
KEY_ID="${APP_STORE_CONNECT_KEY_ID:-}"
KEY_PATH="$HOME/private_keys/AuthKey_${KEY_ID}.p8"

if [[ -z "$ISSUER_ID" || -z "$KEY_ID" ]]; then
  echo "App Store Connect issuer/key secrets are required"
  exit 1
fi

IPA_PATH="$(find "$EXPORT_PATH" -maxdepth 1 -name "*.ipa" | head -n 1)"
if [[ -z "$IPA_PATH" ]]; then
  echo "No IPA found in $EXPORT_PATH"
  exit 1
fi

if [[ ! -f "$KEY_PATH" ]]; then
  echo "API key file not found at $KEY_PATH"
  exit 1
fi

set -x
xcrun altool \
  --upload-app \
  --type ios \
  --file "$IPA_PATH" \
  --apiKey "$KEY_ID" \
  --apiIssuer "$ISSUER_ID"