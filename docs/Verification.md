# Verification Evidence — SK's App Menu 1.0.0 (1)

Date: 2026-11-14. Host: macOS 27.2.1, Apple silicon. Toolchain: Xcode 27.2 (27B52), Swift 6.4.2 in Swift 6 mode. Architecture and Feasibility approved by Siveesh before implementation.

## Build

- Debug app compiled/linked successfully through the canonical `script/build_and_run.sh --verify --manage --store-directory .../Temporary/RuntimeQA`; process existence verified.
- Final source including requested app icons/compact menu compiled through `scripts/test.sh`; TEST SUCCEEDED.
- `scripts/package.sh 1.0.0-local`: Release BUILD SUCCEEDED, then ad-hoc re-signing with Hardened Runtime, strict signature verification, DMG creation. Exit 0.
- App resources verified present: AppIcon.icns, Assets.car, Help.md, original flattened AppIcon.png. Layered Icon Composer source compiled through actool.

## Tests

Final `scripts/test.sh` (xcodebuild project SKsAppMenu, scheme SKsAppMenu, destination platform=macOS, DerivedData): **31 tests, zero failures** (16 discovery/catalog, six persistence, eight app-model, one real launch integration).

Result bundle: `DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_11-45-52-+0300.xcresult`. Full output retained in `Build/Evidence/sks-final-tests.log`.

Core covers recursive vendor folders, bundle boundaries, symlinks/Finder aliases, invalid executables/metadata, denied paths, missing roots, cancellation, duplicate IDs/copies, bookmark moves, ambiguous identity and partial failure retention. Persistence covers preferences across reopened stores, backup/recovery/archive, invalid/newer data, external corruption and write failure. Model covers read-only recovery, suspended saves/newest edits, scan/edit race, coalescing, single-worker cancellation, Add during scan and Locate into a rediscovered copy.

Launch integration creates an executable native fixture outside scan roots, adds it through CatalogModel, calls the production launch method, and verifies that the launched bundle writes its exact resolved URL. Initial assertion failed solely on /var versus /private/var spelling; normalized-location assertion passed. Fixture and temporary settings are removed by test teardown.

Initial discovery behavioral RED, regression RED/GREEN, and scope-specific evidence are recorded in CoreImplementationReport.md and UIImplementationReport.md. No false claim that every UI method received a standalone failing unit test.

## Real installed scan and performance

Production scanner probe: **144 apps, six warnings, zero failed roots, 0.168313166 seconds**. Found Adobe Photoshop 2027 at /Applications/Adobe Photoshop 2027/Adobe Photoshop 2027.app and DaVinci Resolve at /Applications/DaVinci Resolve/DaVinci Resolve.app. Installed bundles were read only and neither vendor app was launched.

1,000 executable fixture bundles: discovery **0.339 seconds**, warm identity reconciliation **0.032 seconds**. Controlled debug measurements; not a general performance guarantee. The native menu's 100ms opening target has not been instrumented; no idle timer or continuous scan runs.

## Runtime and local test installation

- Installed to designated local testing folder `Build/Testing/SK's App Menu.app`, copied from the mounted DMG, rather than replacing any existing launcher in /Applications.
- Launched that app with --manage; process 7922 observed at the exact Build/Testing executable path. Initial ps sample: 142336 KiB RSS and 2.9% CPU during startup; this is not an idle profile.
- Preview settings (one hidden app and one category override) preserved into previously absent normal Application Support storage without overwriting an existing catalog.
- Native UI observation confirmed 144 apps, nested Photoshop listing, searchable catalog, keyboard row selection and available visibility/category controls. Vertical layout defect reproduced visually, corrected, rebuilt and visually verified with list filling the window.
- Native Add picker opened. Further UI control was intermittently invalidated by external input/state changes, so full pointer/picker/Help/About/VoiceOver and light-mode verification is not claimed. Core/model tests and actual launch integration supply separate evidence. User's requested icon/width refinement is compiled and in the running final build; no separate screenshot timing/width measurement claim.

## Packaging/signing

- Artifact: `Release/SKsAppMenu-1.0.0-local.dmg`, approximately 2.3MB.
- hdiutil verify: checksum VALID. Mounted read-only, copied test app, detached successfully.
- codesign --verify --strict on the copied app: exit 0.
- codesign -dv: Identifier com.siveesh.sksappmenu; flags 0x10002 (adhoc,runtime); Signature=adhoc; TeamIdentifier not set; Runtime Version 27.2.0.
- This is a local development package, not Developer ID signed or notarized. Plain Xcode ad-hoc builds disable Hardened Runtime; the package script explicitly re-signs the staged app with --options runtime, and the packaged/test copy flags above are the evidence.

## Diagnostics and limits

Xcode emits an unrelated host CoreSimulator version mismatch, skipped App Intents metadata extraction (no AppIntents dependency), and test-host autoShortcut connection diagnostics. macOS compilation/tests still completed successfully. hdiutil reports command deprecation on this OS while create/verify/detach succeed. No Swift compiler warning or blocking app error was found in the final source build.

macOS 27.0 itself, full VoiceOver narration, light-mode visual QA and production signing/notarization remain unverified. Gatekeeper public-download eligibility is not claimed.

## Cleanup and retained evidence

Package staging directory removed by trap, DMG detached. Test fixture temporary roots cleaned by tests; core RED isolated package removed. Current Debug/Release products, Xcode result bundles, raw evidence in Build/Evidence, current DMG, local testing app, and preview QA settings retained for inspection/recoverability. No broad cleanup, original launcher deletion or user-data cleanup performed. Generated build products remain ignored by Git.

Strict governance verification is run for implementation, QA and documentation at final handoff. Governance is structural evidence, not functional certification.

## 1.0.1 startup and icon correction — 2026-11-14

User reported default management-window opening and absent app icons despite assigned images. SDK NSMenuItem.h and Apple's preferredImageVisibility reference confirm macOS27 defaults image visibility to Automatic and typically hides images. Set each application row to .visible explicitly; do not change global macOS preferences. The new real-menu regression failed with Automatic(rawValue0) versus Visible(rawValue1), then passed. All32 Xcode tests pass; result bundle Test-SKsAppMenu-2026.11.14_11-53-30-+0300.xcresult. Prior final handoff was launched with --manage; normal launch now omits that flag and every utility scene disables restoration as well as suppressing default launch. Explicit management access remains in the menu.

Sources: https://developer.apple.com/documentation/appkit/nsmenuitem/preferredimagevisibility and https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:). No new framework, entitlement or storage change. Release version1.0.1, build2. Logs retained in Build/Evidence. Native startup verification and package results are appended after observation.

Final1.0.1 outcome: Release build succeeded; Release/SKsAppMenu-1.0.1-local.dmg created/checksum verified, mounted read-only and detached. Packaged app strict signature passed; previous local test app archived to Build/Previous-1.0.0 and new app placed at Build/Testing. Process9097 observed with no launch arguments; bundle version1.0.1. Normal Application Support catalog was not modified by deployment. CUA could not bind a window surface to the menu-only app (timeout); functional image-policy verification is the actual NSMenu regression, not an unobserved screenshot. Logs copied to Build/Evidence/sks-101-*.log.

## Dock design preparation —2026-11-14

Read existing app lifecycle/catalog/persistence. Verified Apple's activation policy, Dock reopen and SwiftUI launch/restore documentation. User selected categorized window. Design-only work: no new build, test, runtime or installation performed. Current1.0.1 evidence remains unchanged. Structural governance checks run before design handoff; they do not certify future Dock behavior.

Dock design builder check: no important unanswered planning questions. Strict architecture and feasibility checks each passed with zero warnings. Documentation hook checked at commit. No production implementation or new product validation claimed.

## iOS-on-Mac discovery —1.0.2(4),2026-11-14

Direct user request implemented as scanner compatibility correction while Dock design remains pending approval. Five installed apps use outer .app/Wrapper/<payload>.app/Info.plist plus WrappedBundle link; native Contents/Info.plist assumption produced false warnings. Scanner now supports canonical contained wrapped/flat iOS layouts, requires positive iPhoneOS/LSRequiresIPhoneOS metadata and APPL/executable validation, keeps outer app URLs for launch/icons/identity, and defaults them to iOS Apps. Invalid, unreadable, external-link and ambiguous payloads continue to warn; user category overrides win.

Regression evidence: original iOS fixtures ran RED with five failing assertions, then passed. Permission fixture correctly adds both per-app and partial-root warnings; assertion refined to verify both rather than assume one warning per error. Legacy custom iOS Apps category fixture failed the new built-in name validation; compatibility exception preserves loaded categories/assignments without weakening UI duplicate-name creation rules. Independent read-only reviews found no Important/Critical issues.

Full Xcode suite:37 tests, zero failures (27 core/store and10 app), TEST SUCCEEDED. Result: DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-10-19-+0300.xcresult. Installed production scan:149 apps, one native-bundle warning, zero failed roots; eGlu, Hik-Connect, Krzene, Nuvio and STARZPLAY in iOS Apps. Passwords.app declares native MacOSX/XPC! and is not mislabeled iOS; supporting native XPC app packaging is a separate compatibility item. No iOS application was launched during this metadata check.

Final deployment evidence for1.0.2(4): Release build passed; final local DMG checksum verified, mounted read-only, copied to Build/Testing, strict codesign verification passed and DMG detached. App version/build read back as1.0.2/4, process12766 observed at the testing executable with no launch arguments. Saved catalog contains five iOS Apps records, and every previously saved visibility/category choice compared equal before/after upgrade. Settings were not reset or replaced. Previous local test build retained in Build/Previous-1.0.2-build3, previous1.0.1 in Build/Previous-1.0.1. Staging directories removed by package trap. All packages remain local ad-hoc/runtime builds, not notarized.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

1.0.3(5) deployment verified: Release BUILD SUCCEEDED; local DMG checksum valid; strict packaged-app signature verification passed. Mounted image copied to Build/Testing, detached, and normal menu-only launch observed as process13554; Info.plist reports1.0.3. Previous test app retained in Build/Previous-1.0.2-build4. No preference reset. Raw logs retained in Build/Evidence/sks-103-*.log. Category tooltips removed by source inspection; focused menu regression passes. Full37-test baseline remains1.0.2, not rerun for this styling-only change.

##1.1.0 Dock launcher and Prism icon —2026-11-14

- Final `./scripts/test.sh`: TEST SUCCEEDED,37 core/store +22 app =59 tests, zero failures. Log Build/Evidence/dock-final-tests.log; result DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-44-22-+0300.xcresult.
- Debug `./script/build_and_run.sh --verify --store-directory "$PWD/Temporary/DockRuntimeQA"`: BUILD SUCCEEDED and exact Debug process path verified. Build/Evidence/dock-runtime-build.log retained.
- Isolated catalog seeded saved Dock-on. Native UI showed only launcher on startup, all densities, category icons, iOS Apps5, All Applications149 after corrected selection, search SK Launch Test→one row. Clicking list then Down selected it; Return wrote exact Temporary/LauncherFixture.app URL to Temporary/fixture-launched.txt at12:43:45. No real installed app launched.
- Minimized launcher was restored through normal `/usr/bin/open` application-reopen event, same launcher ID and search/selection retained. Dock-off checkbox changed to0; management remained; Open Launcher reopened window with Dock off. Exact Dock pointer click was not separately exercised.
- Native Icon Composer Default/Dark/Mono previews inspected. Native actool compiled layered AppIcon.icon successfully.1024×1024 export Resources/Branding/AppIcon-Default.png. Metadata version1.1.0 build6; marketing previews excluded from app resources.
- Independent important error-routing finding corrected with regression RED→GREEN. Native All Applications nil selection correction rebuilt and visually verified. Reports DockCoreReport.md and DockUIReport.md preserve scoped test evidence.
- Warnings: skipped AppIntents metadata extraction (no dependency), existing host simulator/autoShortcut/status-item shutdown diagnostics. No Swift compiler error. Public signing/notarization, full VoiceOver/light UI and earliest macOS27.0 runtime remain unqualified.

##1.1.0 final local deployment —2026-11-14

Release BUILD SUCCEEDED; Release/SKsAppMenu-1.1.0-local.dmg created and hdiutil checksum VALID. SHA256 df3082a3b608d3233c30f6eada3acb819eba50afd4f260b49298f5570aa1c442. Mounted read-only, archived previous designated test app to Build/Previous-1.0.3-build5, copied packaged app to Build/Testing/SK's App Menu.app, strict codesign verification passed, detached image successfully. Signature flags0x10002(adhoc,runtime), no TeamIdentifier; this remains a local unnotarized build.

Installed Info.plist reads1.1.0/6; process18736 observed at the exact Build/Testing executable path with no arguments. Normal catalog's149 app UUID/hidden/category choices all compare equal before/after; no SK Launch Test fixture transferred. Normal saved presentation defaults Dock off/Comfortable. Native compiled icon resources AppIcon.icns and Assets.car present. Package staging removed by trap; current/previous test apps, packages, logs and isolated QA store intentionally retained. Installed apps and global Dock/appearance/privacy settings untouched. Raw evidence Build/Evidence/dock-*.log. Full tests59/59 passed before Release packaging. Final strict implementation/qa/documentation checks recorded below after execution.

Final strict implementation, QA and documentation governance checks each passed with zero warnings; git diff --check passed. These structural checks do not replace the functional evidence above.
