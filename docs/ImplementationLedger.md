# Implementation ledger — plan: docs/superpowers/plans/2026-11-14-native-rebuild.md

Approvals: Architecture and Feasibility approved by Siveesh, 2026-11-14. Feature branch feature/native-rebuild; base e309266. Baseline: governance only, no app target/tests existed.
Rulings: current workspace feature branch; checked-in generated Xcode project; no repeat approval prompt (see plan).
Preflight: task 1 produces shared catalog interfaces used by tasks 2/3; exact contract fixed in plan. Task 2 store and model consumed by task 3 UI; model contract supplied before UI implementation. Task 4 covers integration QA and release limitations.

Task 2 persistence: missing PreferencesStore compile RED observed; six recovery/roundtrip/corruption/write-failure tests now GREEN. Raw logs /tmp/sks-store-red.log and /tmp/sks-store-final.log.
Correction: strict verifier initially scanned generated .build/XCBuildData JSON and incorrectly reported template markers. Reproduced with strict implementation verification. Skip known generated directories; retain checks on project source records.
Branding: original menu-panel SVG layers authored in Resources/AppIcon.icon, compiled by actool to AppIcon.icns and Assets.car; flattened export inspected. Relay About reference inspected; user-owned Logo1/Logo2 imagesets copied for consistent About identity. No upstream code/assets imported.
Task 1 implementation evidence: 22 SwiftPM tests, 0 failures (16 core + 6 persistence); 1,000-fixture scan 0.339s, warm merge 0.032s. Real installed scan:144 apps, 6 warnings,0 failed roots,.168s. Photoshop2027 and Resolve found within vendor subfolders.
Task 2 review: persistence store compliant; model external-corruption recovery transition identified and addressed with typed recovery state.
Task 3 integration: Debug app build succeeded. Hosted test target initially duplicated static MenuCore symbols; fixed app-test dependency link:false to use host's types. Dedicated test store env prevents host tests from writing ordinary user settings.
Whole-change review: two Important findings (manual Add/Locate versus stale scan; Locate into already-discovered ambiguous copy). Assigned regression fixes to UI implementer. No Critical finding; no merge/push or installed-app changes.

Task3: both Important review findings fixed RED→GREEN, plus stop/restart regression; full31-test Xcode suite passed. Actual launcher fixture URL proof normalized /var symlink spelling.
User refinement: app icons before submenu layout, concise status/actions, compact long titles with full tooltips and Add shortcut. Final suite passed on refinement source.
Task4: Release build+localDMG created, checksum and ad-hoc/runtime signature verified. Copied into Build/Testing and process at that exact path observed. Preview preferences preserved only into absent normal store. Public release qualifications remain explicit.
Phase lessons bridge invoked for real implementation/QA/documentation corrections; no invented lessons. Branch retained without merge/push as scoped.

## 1.0.1 startup and icon correction — 2026-11-14

User reported default management-window opening and absent app icons despite assigned images. SDK NSMenuItem.h and Apple's preferredImageVisibility reference confirm macOS27 defaults image visibility to Automatic and typically hides images. Set each application row to .visible explicitly; do not change global macOS preferences. The new real-menu regression failed with Automatic(rawValue0) versus Visible(rawValue1), then passed. All32 Xcode tests pass; result bundle Test-SKsAppMenu-2026.11.14_11-53-30-+0300.xcresult. Prior final handoff was launched with --manage; normal launch now omits that flag and every utility scene disables restoration as well as suppressing default launch. Explicit management access remains in the menu.

Sources: https://developer.apple.com/documentation/appkit/nsmenuitem/preferredimagevisibility and https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:). No new framework, entitlement or storage change. Release version1.0.1, build2. Logs retained in Build/Evidence. Native startup verification and package results are appended after observation.

Final1.0.1 outcome: Release build succeeded; Release/SKsAppMenu-1.0.1-local.dmg created/checksum verified, mounted read-only and detached. Packaged app strict signature passed; previous local test app archived to Build/Previous-1.0.0 and new app placed at Build/Testing. Process9097 observed with no launch arguments; bundle version1.0.1. Normal Application Support catalog was not modified by deployment. CUA could not bind a window surface to the menu-only app (timeout); functional image-policy verification is the actual NSMenu regression, not an unobserved screenshot. Logs copied to Build/Evidence/sks-101-*.log.

## iOS-on-Mac discovery —1.0.2(4),2026-11-14

Direct user request implemented as scanner compatibility correction while Dock design remains pending approval. Five installed apps use outer .app/Wrapper/<payload>.app/Info.plist plus WrappedBundle link; native Contents/Info.plist assumption produced false warnings. Scanner now supports canonical contained wrapped/flat iOS layouts, requires positive iPhoneOS/LSRequiresIPhoneOS metadata and APPL/executable validation, keeps outer app URLs for launch/icons/identity, and defaults them to iOS Apps. Invalid, unreadable, external-link and ambiguous payloads continue to warn; user category overrides win.

Regression evidence: original iOS fixtures ran RED with five failing assertions, then passed. Permission fixture correctly adds both per-app and partial-root warnings; assertion refined to verify both rather than assume one warning per error. Legacy custom iOS Apps category fixture failed the new built-in name validation; compatibility exception preserves loaded categories/assignments without weakening UI duplicate-name creation rules. Independent read-only reviews found no Important/Critical issues.

Full Xcode suite:37 tests, zero failures (27 core/store and10 app), TEST SUCCEEDED. Result: DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-10-19-+0300.xcresult. Installed production scan:149 apps, one native-bundle warning, zero failed roots; eGlu, Hik-Connect, Krzene, Nuvio and STARZPLAY in iOS Apps. Passwords.app declares native MacOSX/XPC! and is not mislabeled iOS; supporting native XPC app packaging is a separate compatibility item. No iOS application was launched during this metadata check.

Final deployment evidence for1.0.2(4): Release build passed; final local DMG checksum verified, mounted read-only, copied to Build/Testing, strict codesign verification passed and DMG detached. App version/build read back as1.0.2/4, process12766 observed at the testing executable with no launch arguments. Saved catalog contains five iOS Apps records, and every previously saved visibility/category choice compared equal before/after upgrade. Settings were not reset or replaced. Previous local test build retained in Build/Previous-1.0.2-build3, previous1.0.1 in Build/Previous-1.0.1. Staging directories removed by package trap. All packages remain local ad-hoc/runtime builds, not notarized.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

1.0.3(5) deployment verified: Release BUILD SUCCEEDED; local DMG checksum valid; strict packaged-app signature verification passed. Mounted image copied to Build/Testing, detached, and normal menu-only launch observed as process13554; Info.plist reports1.0.3. Previous test app retained in Build/Previous-1.0.2-build4. No preference reset. Raw logs retained in Build/Evidence/sks-103-*.log. Category tooltips removed by source inspection; focused menu regression passes. Full37-test baseline remains1.0.2, not rerun for this styling-only change.

Dock milestone approved2026-11-14; base44efcc7 on feature/native-rebuild. Plan docs/superpowers/plans/2026-11-14-dock-launcher.md. Core prefs/UI/branding ownership divided; no duplicate store or app process. Current baseline1.0.3; prior full37 tests plus focused menu test.

##1.1.0 integration QA

Dock core/UI work integrated with approved design and native Prism icon. Final59 tests pass; native runtime exercised category/sidebar/search/density, controlled keyboard launch and minimized reopen. Root corrected the native List nil-tag All Applications row with explicit enum identity after visual reproduction; category→All was verified on rebuilt product. Independent minimized error-routing regression also corrected. Resources/Help.md and docs/Help.md synchronized; README/version/changelog updated. Final packaging/deployment evidence in Verification.md.
