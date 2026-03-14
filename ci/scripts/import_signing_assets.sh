#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${BUILD_CERTIFICATE_BASE64:-}" ]] || [[ -z "${BUILD_PROVISION_PROFILE_BASE64:-}" ]] || [[ -z "${P12_PASSWORD:-}" ]] || [[ -z "${KEYCHAIN_PASSWORD:-}" ]]; then
  echo "Manual signing assets not fully provided. Skipping import and relying on automatic signing."
  exit 0
fi

CERT_PATH="$RUNNER_TEMP/build_certificate.p12"
PP_PATH="$RUNNER_TEMP/profile.mobileprovision"
KEYCHAIN_PATH="$RUNNER_TEMP/app-signing.keychain-db"

echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o "$CERT_PATH"
echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode -o "$PP_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security import "$CERT_PATH" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security list-keychain -d user -s "$KEYCHAIN_PATH" login.keychain-db
security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
cp "$PP_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/"

echo "Manual signing assets imported."