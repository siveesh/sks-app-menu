# Session Handoff

Updated2026-11-14. SK's App Menu1.1.0(6), feature/native-rebuild. No merge/push. All five local milestone phases complete; architecture/feasibility and Dock design explicitly approved.

## Summary

Optional same-process Dock launcher delivered with categorized sidebar, search, shared catalog/preferences, exact-copy launch, keyboard selection/Return and Compact/Comfortable/Spacious density. Show in Dock is off by default; Open Launcher works independently. Enabling/reopen restores singleton launcher, including minimized. Management opens only when requested. Existing menu image visibility/category-tooltip behavior and iOS Apps classification preserved. Original Prism Launcher layered Icon Composer asset supports native glass and Default/Dark/Mono appearances.

## Files changed

Core presentation preferences/decoder and compatibility tests; native Dock controller/window relay/launcher; model/management/menu controls; icon SVG/JSON/preview and About; project metadata1.1.0/6; Help, README, changelog and governance records. See DockCoreReport.md, DockUIReport.md and IconDesign.md for implementation details.

## Build and test result

Debug and Release builds succeeded on macOS27.2.1, Xcode27.2/Swift6.4.2. Final full Xcode suite59 tests (37core/store,22app), zero failures. Result Test-SKsAppMenu-2026.11.14_12-44-22-+0300.xcresult. Raw logs Build/Evidence/dock-final-tests.log and dock-package.log. Native isolated QA verified all densities, category→All, iOS Apps5/icons, search, controlled Down/Return launch, minimized reopen, Dock disable and launcher access with Dock off. Default/Dark/Mono icon previews inspected in Icon Composer. Exact Dock mouse click, light launcher appearance and full VoiceOver are not claimed.

## Installed build

Build/Testing/SK's App Menu.app copied from read-only mounted Release/SKsAppMenu-1.1.0-local.dmg; checksum VALID, strict signature passed, image detached. Installed version1.1.0/6; process18736 at exact testing executable with no launch arguments. Signature ad-hoc/runtime, not Developer ID signed or notarized. SHA256 and exact commands/evidence in Verification.md.

## Preferences and cleanup

Normal Application Support catalog preserved: all149 preexisting UUID/hidden/category choices equal after launch. No isolated QA fixture transferred. Dock off/Comfortable defaults saved. Previous test app archived in Build/Previous-1.0.3-build5. Package staging removed by trap; prior retained builds/packages, current products, evidence and isolated Temporary/DockRuntimeQA intentionally retained for recovery/debug. No installed application or global Dock/appearance/privacy preference altered.

## Documentation and diagnostics

Help/README/Architecture/Feasibility/Snapshot/QA/Verification/Roadmap/Issues/Changelog updated. Actual lessons recorded globally: explicit All selection identity, minimized error restoration and Icon Composer front-to-back layers. /usr/bin/python3 required because default pyenv shim is broken. Xcode emits existing host simulator/autoShortcut/status-item shutdown diagnostics and skipped AppIntents extraction; hdiutil commands deprecated but passed. No Swift compiler errors.

## Known issues, risks and next step

Public Developer ID/notarization and licence selection remain; full VoiceOver/light appearance/macOS27.0 qualification pending. Passwords.app is native MacOSX/XPC!, excluded by APPL validation and still warns; it is not an iOS app. Old app versions can ignore/drop the optional presentation block, so retain latest build for saved appearance. No new runtime dependency, entitlement, network service or menu performance guarantee. User acceptance of the delivered Dock launcher/icon is next; there is no pending design approval.

## Useful commands

`./script/build_and_run.sh --verify` canonical Debug build/run. `./scripts/test.sh` full suite with isolated store; `swift test` core. `./scripts/package.sh <new-version>` refuses existing artifact. Do not run simultaneous Xcode builds/tests against DerivedData. Use isolated --store-directory for QA, never replace normal catalog with QA data.
