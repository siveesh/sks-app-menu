#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
xcodebuild -project "$ROOT_DIR/SKsAppMenu.xcodeproj" -scheme SKsAppMenu -destination 'platform=macOS' -derivedDataPath "$ROOT_DIR/DerivedData" test
