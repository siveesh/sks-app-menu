#!/usr/bin/env bash
set -euo pipefail
MODE="${1:-run}"
if [[ $# -gt 0 ]]; then shift; fi
APP_ARGS=("$@")
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/DerivedData/Build/Products/Debug/SK's App Menu.app"
case "$MODE" in run|--verify|--debug|--logs|--telemetry) ;; *) echo 'usage: build_and_run.sh [--verify|--debug|--logs|--telemetry]' >&2; exit 2;; esac
pkill -x SKsAppMenu >/dev/null 2>&1 || true
xcodebuild -project "$ROOT_DIR/SKsAppMenu.xcodeproj" -scheme SKsAppMenu -configuration Debug -derivedDataPath "$ROOT_DIR/DerivedData" build
case "$MODE" in
  --debug) lldb -- "$APP_BUNDLE/Contents/MacOS/SKsAppMenu" "${APP_ARGS[@]}" ;;
  --logs|--telemetry)
    /usr/bin/open -n "$APP_BUNDLE" --args "${APP_ARGS[@]}"
    /usr/bin/log stream --info --style compact --predicate 'process == "SKsAppMenu"' ;;
  --verify)
    /usr/bin/open -n "$APP_BUNDLE" --args "${APP_ARGS[@]}"
    sleep 1
    pgrep -x SKsAppMenu >/dev/null
    echo "Running: $APP_BUNDLE" ;;
  *) /usr/bin/open -n "$APP_BUNDLE" --args "${APP_ARGS[@]}" ;;
esac
