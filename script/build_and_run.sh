#!/usr/bin/env bash
set -euo pipefail
MODE="${1:-run}"
if [[ $# -gt 0 ]]; then shift; fi
APP_ARGS=("$@")
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/DerivedData/Build/Products/Debug/SK's App Menu.app"
case "$MODE" in run|--verify|--debug|--logs|--telemetry) ;; *) echo 'usage: build_and_run.sh [--verify|--debug|--logs|--telemetry]' >&2; exit 2;; esac
pkill -x SKsAppMenu >/dev/null 2>&1 || true
# Wait for the old process before Xcode updates the same bundle in place.
for ((attempt = 0; attempt < 50; attempt++)); do
  if ! pgrep -x SKsAppMenu >/dev/null; then break; fi
  sleep 0.1
done
if pgrep -x SKsAppMenu >/dev/null; then
  echo 'The previous test app is still running. Close it before rebuilding.' >&2
  exit 1
fi
xcodebuild -project "$ROOT_DIR/SKsAppMenu.xcodeproj" -scheme SKsAppMenu -configuration Debug -derivedDataPath "$ROOT_DIR/DerivedData" build
if [[ ! -x "$APP_BUNDLE/Contents/MacOS/SKsAppMenu" ]]; then
  echo "Built app executable is missing: $APP_BUNDLE" >&2
  exit 1
fi
case "$MODE" in
  --debug) lldb -- "$APP_BUNDLE/Contents/MacOS/SKsAppMenu" "${APP_ARGS[@]}" ;;
  --logs|--telemetry)
    /usr/bin/open -n -a "$APP_BUNDLE" --args "${APP_ARGS[@]}"
    /usr/bin/log stream --info --style compact --predicate 'process == "SKsAppMenu"' ;;
  --verify)
    /usr/bin/open -n -a "$APP_BUNDLE" --args "${APP_ARGS[@]}"
    sleep 1
    pgrep -x SKsAppMenu >/dev/null
    echo "Running: $APP_BUNDLE" ;;
  *) /usr/bin/open -n -a "$APP_BUNDLE" --args "${APP_ARGS[@]}" ;;
esac
