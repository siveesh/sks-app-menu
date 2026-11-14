# Dock launcher implementation report

Date: 2026-11-14. Approved Dock design/plan used; implementation task2 only. Root owns final branding, runtime acceptance, packaging, governance/phase records and commit.

## Changes

- CatalogModel owns density and persisted Dock preference inside the same CatalogDocument and revision-based save loop. Refresh only replaces apps, retaining current presentation edits. Read-only recovery blocks appearance mutations. Successful backup/reset load reapplies presentation through the same policy boundary.
- DockPresenceController performs synchronous MainActor activation-policy transitions, validates Boolean success, and changes saved/effective state only after success. Failures retain prior saved/effective values and expose a Dock warning. Saved-on startup requests Launcher; normal default-off startup requests no scene. Reopen routes only to Launcher even when other windows exist. Closing Launcher keeps the process alive.
- SwiftUI owns the singleton Window scene with suppressed default launch, disabled restoration and screen-clamped initial placement. WindowActionRelay coalesces early requests, cancels pending launcher requests on disable, and restores the registered existing minimized launcher. A narrow NSViewRepresentable captures the SwiftUI-owned window; it never constructs NSWindow. A disable arriving between scene scheduling and view attachment closes that scheduled launcher on attachment.
- Native NavigationSplitView sidebar lists All Applications and nonempty visible categories. List filtering shares CatalogModel's hidden/missing exclusion and searches selected category by name/category/full path. Rows show real installed icons, full-path tooltips, unverified indicators, keyboard Return and native selection. The toolbar exposes persisted density, Refresh, Add and Manage. Compact20/32/13, Comfortable28/44/14 and Spacious40/60/16 sizes match the approved minimum dimensions. Rows may grow for wrapped text.
- Status menu adds Open Launcher and Show in Dock. Management adds Appearance controls; explicit Open Launcher uses the same restore relay. Existing menu icon `.visible` policy and category headings' absent tooltips remain. Launcher errors provide a management route; menu launching retains existing management error routing.

## Verification

Behavioral RED: existing WindowActionRelay dropped two early launcher requests, producing [] instead of [launcher]. Captured in Build/Evidence/dock-ui-red.log; run also includes core worker's intentional presentation-decoding RED assertions. Initial UI test compile found NSCondition locking directly in an async fixture closure; moving that blocking work into a synchronous helper corrected the fixture without changing production behavior.

Automated additions cover queued request coalescing, policy failure while enabling/disabling, loaded-on activation failure, default-off/no-management routing, saved-on startup, early reopen, canceled delayed open, injected existing-window restoration, density/Dock edits during suspended save and scan publication, backup recovery policy application, read-only protection and visible category search filtering. Policy and window actions are injected dependencies; no test-only production branches.

Full Xcode suite evidence is appended after the final source build. Native visual/pointer/minimize/Dock behavior still requires root's runtime pass; no runtime acceptance or packaged deployment claim is made here.

## Scope and limits

Exact installed application URL launching uses the existing CatalogModel.launch service; existing launch integration remains in the full suite. Preferences failures keep the existing unsaved warning/quit-draining behavior. No external dependencies, manual NSWindow construction, Dock preference edits, login behavior, schema bump, identity reset or real user-store mutation was introduced. All Xcode test execution uses the configured isolated Temporary/XcodeTestStore.

Final task2 source verification: `./scripts/test.sh` exited0 with **TEST SUCCEEDED**,58 tests and zero failures (37 core +21 app), including11 new Dock/launcher tests. Result: `DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-28-14-+0300.xcresult`; log `Build/Evidence/dock-ui-green.log`. This includes the final management-button relay correction. During that edit, an overly broad textual replacement also touched CategoryManagementView's initializer; compiler identified the extra argument, it was removed, and this final full run passed. Existing CoreSimulator host-version, App Intents no-dependency and hosted status-item teardown diagnostics remain nonblocking; no Swift compile warnings/errors in the passing run.

## Independent review correction

Review identified that a minimized launcher counted as present, causing MenuController to skip opening management while its error alert remained minimized. Error publication now explicitly raises/restores the existing launcher, or opens management when there is no launcher. Added `testMenuLaunchFailureRestoresMinimizedLauncherForRecovery`: a real production NSWorkspace failure publishes the error through MenuController; a minimized-window-state fixture and injected restore action verify launcher routing and absence of a duplicate scene. Hosted accessory apps cannot reliably perform real Dock miniaturization, so only that external window state is supplied by the fixture.

RED evidence: the expected restore assertion reached XCTest's failure handler with [] rather than [launcher]; the failure report stalled during host CoreSymbolication file opening. `Build/Evidence/dock-error-routing-sample2.txt` captures that exact `XCTAssertEqual` failure-reporting stack at DockLauncherTests.swift42; the interrupted run's log is `dock-error-routing-red.log`. The initial real-miniaturize fixture's setup failure is separately captured in `dock-error-routing-sample.txt` and is not the behavioral RED evidence.

After the routing correction, the full Xcode suite completed **59 tests, zero failures, TEST SUCCEEDED**. Log `Build/Evidence/dock-error-routing-green.log`; result `DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-33-13-+0300.xcresult`. This run spent about75 seconds starting tests (sample shows XCTest loading a bundle through CFBundle/open); it then completed without app test failures. A permissions explanation was considered but remains unverified; no privacy/system settings were changed. A redundant fallback focused run in /tmp DerivedData was already underway when the original full run's completion was observed.

Fallback focused confirmation also passed (one test, zero failures): `Build/Evidence/dock-error-routing-focused-green.log`, result `/tmp/sks-dock-review-qa/Logs/Test/Test-SKsAppMenu-2026.11.14_12-34-45-+0300.xcresult`. /tmp products are test-only and do not replace the normal DerivedData app intended for root's native QA. Source remains frozen after the59-test full result.

Root integration completed: native runtime and package/deployment evidence are now recorded in Verification.md. Final full suite59 tests passes after the All Applications selection correction.
