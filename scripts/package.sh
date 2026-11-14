#!/usr/bin/env bash
# Explicit Developer ID signing is supported; notarization is a separate workflow.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-1.0.0-local}"
SIGNING_IDENTITY="${SK_APP_MENU_SIGNING_IDENTITY:--}"
case "$VERSION" in *[!a-zA-Z0-9._-]*|'') echo 'Invalid artifact version' >&2; exit 2;; esac
OUT="$ROOT_DIR/Release/SKsAppMenu-$VERSION.dmg"
if [[ -e "$OUT" ]]; then echo "Artifact exists; use a new version: $OUT" >&2; exit 1; fi
mkdir -p "$ROOT_DIR/Release" "$ROOT_DIR/Temporary"
xcodebuild -project "$ROOT_DIR/SKsAppMenu.xcodeproj" -scheme SKsAppMenu -configuration Release -derivedDataPath "$ROOT_DIR/DerivedData" build
STAGE="$(mktemp -d "$ROOT_DIR/Temporary/package.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
APP="$STAGE/SK's App Menu.app"
ditto "$ROOT_DIR/DerivedData/Build/Products/Release/SK's App Menu.app" "$APP"
if [[ "$SIGNING_IDENTITY" == '-' ]]; then
  codesign --force --sign - --options runtime "$APP"
  SIGNING_NOTE='This build is ad-hoc signed with Hardened Runtime, not Developer ID signed or notarized.'
else
  codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp "$APP"
  SIGNING_NOTE='This build is signed with a Developer ID Application certificate and Hardened Runtime. It has not been notarized.'
fi
codesign --verify --strict "$APP"
codesign --display --verbose=2 "$APP"
ln -s /Applications "$STAGE/Applications"
cat > "$STAGE/Read Me.txt" <<TEXT
SK's App Menu

Requires macOS 27+ on Apple silicon.
Drag SK's App Menu.app to Applications, then open it. Choose Show in Dock or Open Launcher for the categorized icon grid. It is separate from the original ApplicationMenu app. Quit the app before replacing an earlier build.

$SIGNING_NOTE macOS may prevent opening an unnotarized download under Gatekeeper. Do not disable system security. Public distribution requires Apple notarization.

Settings are stored in ~/Library/Application Support/com.siveesh.sksappmenu/catalog.json. Hiding or recategorizing changes only this launcher's preferences. Help is available in the menu. Quit via the menu before moving or removing the app.
TEXT
hdiutil create -volname "SK's App Menu" -srcfolder "$STAGE" -format UDZO "$OUT"
if [[ "$SIGNING_IDENTITY" != '-' ]]; then
  codesign --sign "$SIGNING_IDENTITY" --timestamp "$OUT"
  codesign --verify --strict "$OUT"
fi
echo "Packaged artifact (not notarized): $OUT"
