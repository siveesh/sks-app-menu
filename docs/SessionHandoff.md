# Session Handoff

Updated2026-11-14. SK's App Menu1.2.1(9), feature/native-rebuild; no merge/push. Direct user request: grid right-click hide, default hide Uninstall names, investigate replaced window buttons.

## Summary and files

Grid contextMenu Hide Application calls shared guarded CatalogModel.setHidden; read-only catalog disables action. AppRecord now tracks visibilityIsUserSet, defaults name-matched uninstallers hidden, strictly decodes old/new records and marks explicit edits. Reconciler and Locate refresh automatic defaults when names change. Shared hiding affects menu and grid; Manage restores apps persistently. Existing hidden legacy choices remain explicit; old visible Uninstall matches intentionally adopt new default. Added Core/model regressions, Help/README/version/project/governance updates. No schema bump, new package dependency or entitlement.

## Window-control finding

User confirmed purple screen-sharing icon. Native accessibility identifies Window sharing; macOS owns capture/sharing presentation while visual QA inspects windows. Standard SwiftUI Window chrome remains. No app replacement/suppression or privacy setting change. Cmd-W closes, Cmd-M minimizes; documented in Help. Apple system-capture reference in Architecture/Feasibility. No source fix required for this confirmed system behavior.

## Build and test evidence

Debug test build and Release package succeed. Final70 Xcode tests (42core/store,28app), zero failures, TEST SUCCEEDED. Result Test-SKsAppMenu-2026.11.14_1-24-20-+0300.xcresult; Build/Evidence/hiding-final-tests.log. RED behavior failures logged before implementation. Tests cover name defaults, migration, strict marker type, automatic encode/rename and explicit restore through real-store scan/restart. Native signed isolated right-click action removed controlled fixture from grid without launching; JSON retained hidden=true/explicit ownership. Fixture timestamp unchanged. Broader manual VoiceOver/light/earliest-OS qualification remains open.

## Installed app and package

Build/Testing/SK's App Menu.app copied from Release/SKsAppMenu-1.2.1-developer-id.dmg; checksum VALID, strict app/DMG signature and app deep verification passed, read-only image detached. Installed1.2.1/9 process25569 observed at exact executable, no launch args. App+DMG Developer ID signed Siveesh Kodapully/MURZTM33SD, secure timestamps, app Hardened Runtime. Not notarized. Exact SHA256/evidence in Verification.md.

## Data and cleanup

149 prior UUIDs/categories and all presentation settings retained. Only intentional visible→hidden migration for three Uninstall-named entries; existing hidden copy retained. No QA fixture transferred. Prior test build preserved Build/Previous-1.2.0-build8. Package staging removed by trap/mount detached. Current/prior artifacts, signed Build/HidingQA, isolated store and diagnostic evidence intentionally retained. No installed app or global privacy/Dock/appearance edits. Generated artifacts ignored by Git.

## Documentation, diagnostics and next step

Five phase documents/Help/README/Changelog/Verification/Handoff updated. Global actual lesson: identify OS capture indicators before interpreting them as app-chrome regressions. Existing host-test diagnostics/hdiutil deprecation nonblocking; use /usr/bin/python3 because default shim is broken. Remaining notarization/licence, full VoiceOver/light/macOS27.0 and earlier Codex launch-dialog observation (exact original missing URL unconfirmed, no recent recurrence). Older app versions may drop new ownership metadata on rewrite; use current build for durable restoration. Next: user acceptance; no pending design approval.

## Commands

`./script/build_and_run.sh --verify` canonical Debug, --store-directory for isolated QA. `./scripts/test.sh` full suite; `swift test` core. `SK_APP_MENU_SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)" ./scripts/package.sh <new-artifact-version>` signs without notarizing and refuses overwrite. Avoid simultaneous Xcode commands on DerivedData; never copy QA store into normal storage. Complete native inspection sessions when finished so OS capture presentation can end.
