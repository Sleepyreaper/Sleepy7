#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

ISSUER_ID = os.getenv("APP_STORE_CONNECT_ISSUER_ID", "")
KEY_ID = os.getenv("APP_STORE_CONNECT_KEY_ID", "")
GROUP_ID = os.getenv("TESTFLIGHT_BETA_GROUP_ID", "")
KEY_PATH = Path.home() / "private_keys" / f"AuthKey_{KEY_ID}.p8"

def run(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr, file=sys.stderr)
        sys.exit(result.returncode)
    return result.stdout.strip()

def main():
    if not ISSUER_ID or not KEY_ID:
      print("Missing App Store Connect API credentials", file=sys.stderr)
      sys.exit(1)

    if not KEY_PATH.exists():
      print(f"Missing API key file: {KEY_PATH}", file=sys.stderr)
      sys.exit(1)

    if not GROUP_ID:
      print("TESTFLIGHT_BETA_GROUP_ID not set. Nothing to manage.")
      return

    print(f"Beta group configured: {GROUP_ID}")
    print("Dude, this script is the hook point for beta group automation.")
    print("Use it to associate newly uploaded builds with pre-created groups via App Store Connect tooling/API.")
    print("Kept intentionally conservative so we don't do bogus mutations without explicit app/group IDs.")

if __name__ == "__main__":
    main()