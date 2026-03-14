#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/private_keys"

if [[ -z "${APP_STORE_CONNECT_PRIVATE_KEY:-}" ]]; then
  echo "APP_STORE_CONNECT_PRIVATE_KEY secret is not set"
  exit 1
fi

if [[ -z "${APP_STORE_CONNECT_KEY_ID:-}" ]]; then
  echo "APP_STORE_CONNECT_KEY_ID secret is not set"
  exit 1
fi

KEY_PATH="$HOME/private_keys/AuthKey_${APP_STORE_CONNECT_KEY_ID}.p8"

printf "%s" "${APP_STORE_CONNECT_PRIVATE_KEY}" > "${KEY_PATH}"
chmod 600 "${KEY_PATH}"

echo "App Store Connect API key installed at ${KEY_PATH}"