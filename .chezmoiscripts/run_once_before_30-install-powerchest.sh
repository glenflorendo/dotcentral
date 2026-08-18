#!/bin/bash

set -euo pipefail

APP_NAME="PowerChest"
REPO="scripsweave/PowerChest"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

if [[ -d "/Applications/${APP_NAME}.app" ]]; then
  echo "${APP_NAME} is already installed."
  exit 0
fi

TMP_DIR="$(mktemp -d)"
MOUNT_DIR="${TMP_DIR}/mount"

cleanup() {
  hdiutil detach "$MOUNT_DIR" -quiet 2>/dev/null || true
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$MOUNT_DIR"

echo "Finding latest ${APP_NAME} release..."

DMG_URL="$(
  curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    "$API_URL" |
  jq -r '
    .assets[]
    | select(.name | test("^PowerChest-.*\\.dmg$"))
    | .browser_download_url
  ' |
  head -n 1
)"

if [[ -z "$DMG_URL" || "$DMG_URL" == "null" ]]; then
  echo "Could not find a PowerChest DMG in the latest GitHub release." >&2
  exit 1
fi

DMG_PATH="${TMP_DIR}/PowerChest.dmg"

echo "Downloading ${APP_NAME}..."
curl -fL "$DMG_URL" -o "$DMG_PATH"

echo "Mounting disk image..."
hdiutil attach "$DMG_PATH" \
  -mountpoint "$MOUNT_DIR" \
  -nobrowse \
  -quiet

if [[ ! -d "$MOUNT_DIR/${APP_NAME}.app" ]]; then
  echo "${APP_NAME}.app was not found in the disk image." >&2
  exit 1
fi

echo "Installing ${APP_NAME}..."
ditto "$MOUNT_DIR/${APP_NAME}.app" "/Applications/${APP_NAME}.app"

echo "${APP_NAME} installed."
