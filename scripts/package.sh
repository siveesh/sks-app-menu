#!/usr/bin/env bash
# Produces a clearly labeled local/ad-hoc development DMG, never a notarization claim.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-1.0.0-local}"
case "$VERSION" in *[!a-zA-Z0-9._-]*|'') echo 'Invalid artifact version' >&2; exit 2;; esac
OUT="$ROOT_DIR/Release/SKsAppMenu-$VERSION.dmg"
if [[ -e "$OUT" ]]; then echo "Artifact exists; use a new version: $OUT" >&2; exit 1; fi
mkdir -p "$ROOT_DIR/Release" "$ROOT_DIR/Temporary"
xcodebuild -project "$ROOT_DIR/SKsAppMenu.xcodeproj" -scheme SKsAppMenu -configuration Release -derivedDataPath "$ROOT_DIR/DerivedData" build
STAGE="$(mktemp -d "$ROOT_DIR/Temporary/package.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
APP="$STAGE/SK's App Menu.app"
ditto "$ROOT_DIR/DerivedData/Build/Products/Release/SK's App Menu.app" "$APP"
codesign --force --sign - --options runtime "$APP"
codesign --verify --strict "$APP"
ln -s /Applications "$STAGE/Applications"
cat > "$STAGE/Read Me.txt" <<'TEXT'
SK's App Menu — local development build

Requires macOS 27+ on Apple silicon.
Drag SK's App Menu.app to Applications, then open it. Click its menu-bar icon to launch apps or Manage Applications. It is separate from the original ApplicationMenu app.

This build is ad-hoc signed with Hardened Runtime, not Developer ID signed or notarized. macOS may prevent opening it under Gatekeeper. Do not disable system security. A public distribution build needs Developer ID signing and Apple notarization.

Settings are stored in ~/Library/Application Support/com.siveesh.sksappmenu/catalog.json. Hiding or recategorizing changes only this launcher's preferences. Help is available in the menu. Quit via the menu before moving or removing the app.
TEXT
hdiutil create -volname "SK's App Menu" -srcfolder "$STAGE" -format UDZO "$OUT"
echo "Local development artifact: $OUT"
