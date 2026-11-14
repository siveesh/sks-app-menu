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

## 1.1.1 refresh-warning preference —2026-11-14

- RED Build/Evidence/warnings-red.log: expected encoded boolean/default, malformed type rejection and menu action fail against prior implementation. Initial GREEN61 tests in warnings-green.log.
- Final full `./scripts/test.sh`: TEST SUCCEEDED,62 tests/zero failures (38core/store,24app). Build/Evidence/warnings-final-tests.log; DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-51-40-+0300.xcresult. Core protects old-file defaults and invalid values; real persisted menu integration checks restart/re-enable; critical failure test confirms raw diagnostics retained and recovery still visible/read-only edits rejected.
- Debug canonical build/run with --store-directory Temporary/WarningsRuntimeQA: BUILD SUCCEEDED, exact executable path observed. Log warnings-runtime-build.log. Isolated native inspection showed banner hidden with saved hideRefreshWarnings=true, management checkbox1 and collapsed Refresh warnings(1) retained. Native pointer re-enable was interrupted by external-state/noWindowsAvailable; no claim of complete pointer round-trip. No changes to normal user preferences during isolated QA.
- Source review: menu and launcher consume filtered scan diagnostics; management keeps raw diagnostics. Recovery/save/Dock notices remain independent; operation-error alerts unchanged. No scanner, entitlement, dependency or runtime-performance changes. Existing host diagnostics/hdiutil deprecation remain nonblocking.

Final1.1.1 deployment: Release BUILD SUCCEEDED; DMG checksum VALID; SHA256 afc7b4d7127e4d0a062ad33794e66ea9da2768d145a62c853fe200f3d2b030e4. Mounted read-only, copied packaged app to Build/Testing after archiving previous test app in Build/Previous-1.1.0-build6, strict signature verified, detached. Signature ad-hoc/runtime flags0x10002, no team identity/notarization. Installed Info.plist1.1.1/7 and process20258 at exact Build/Testing executable with no arguments observed. All149 prior UUID/hidden/category choices and saved Dock/density equal before/after; new option defaultsfalse; no isolated QA store copied. Package staging removed by trap, earlier builds/evidence/QA stores intentionally retained. Logs Build/Evidence/warnings-package.log, warnings-dmg-*.log, warnings-installed-signature.log. Strict implementation/QA/documentation governance each passed with zero warnings; git diff --check passed.

## 1.2.0 grid and Developer ID signing —2026-11-14

- Focused grid navigation/layout tests ran RED against unimplemented helpers: real assertions failed for adaptive columns, row/column edges, partial last rows and filtered/empty selections. Log Build/Evidence/grid-navigation-red.log. Implemented native lazy grid and navigation, then65-test full suite passed (grid-first-green.log).
- Final `./scripts/test.sh`: TEST SUCCEEDED,65 tests/zero failures (38core/store,27app); Build/Evidence/grid-final-tests.log; DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_1-11-17-+0300.xcresult.
- Native signed candidate at stable Build/SignedGridQA path: Comfortable grid at760px (four columns) and1000px (six), search SK Launch Test→one result, click grid/Down selected tile, Return wrote exact Temporary/LauncherFixture.app URL at13:07:37. Compact40px/five columns at760 and Spacious72px/three columns at760 visually inspected using isolated saved preferences. Native UI metadata retained category sidebar/search; no installed user app launched. Pointer-based repeated density switches were affected by external-state guard; preseeded isolated stores verified the other density renders. All three signed launches had no file-not-found pop-up.
- Debug canonical revised script --verify --store-directory Temporary/GridRuntimeQA: BUILD SUCCEEDED and exact executable running; Build/Evidence/grid-relaunch-check.log. Uses explicit open -a, waits for old process and validates executable before relaunch.
- Startup dialog: user says macOS pop-up during Codex testing. Read-only normal catalog149 apps/manual0/unavailable0 loads; production scan149 apps/failedRoots0, only Passwords non-APPL warning. Existing bundle/executable/help/assets and LaunchServices target checked. Finder log12:53:50 POSIX2→fnfErr(-43) near native getApp(Debug path) timeout; lsd trust errors also present around hosted tests. Missing path was N/A and causal link is unconfirmed. Raw scoped log grid-launch-dialog-investigation.log. No scanner/persistence changes or warning suppression claimed as a source fix. No recurrence under final stable signed launch workflow; do not assert exact historical cause fixed.
- User explicitly chose Developer ID Application certificate. Final command SK_APP_MENU_SIGNING_IDENTITY=<installed certificate fingerprint> ./scripts/package.sh 1.2.0-developer-id; Release BUILD SUCCEEDED. App and DMG actual Authority=Developer ID Application: Siveesh Kodapully (MURZTM33SD), secure timestamps and TeamIdentifier=MURZTM33SD verified. App runtime flags0x10000; strict deep code verification succeeds. No certificate/private key export, no signing entitlement exceptions and no notarization submission.
- Final DMG hdiutil checksum VALID, strict signature verified; SHA25648bc91ca101863f83cf8cb3f43bf446e8c898dd743b8137cd8a9cfe72896a149. Mounted read-only, previous designated test app archived in Build/Previous-1.1.1-build7, packaged app copied to Build/Testing/SK's App Menu.app, image detached. Installed1.2.0/8 and process23589 at exact testing path with no args observed. Normal149 app UUID/hidden/category choices and ALL presentation preferences compare equal before/after. No QA fixture transferred.
- Package staging removed by trap. First signed candidate retained in Release/RetainedCandidates and Build/SignedGridQA, isolated density stores, logs, result bundles and previous versions retained for recovery. No user-data cleanup or installed-app/global Dock/appearance/privacy change. Existing host simulator/autoShortcut/status-item/AppIntents diagnostics and hdiutil deprecation remain; no Swift compile errors. Final structural checks recorded after execution.

Final strict implementation, QA and documentation governance checks each passed with zero warnings; git diff --check passed. Structural verification complements the actual build/test/signature/native evidence above.

## 1.2.1 grid context hiding/uninstaller defaults —2026-11-14

- Behavioral RED Build/Evidence/hiding-red.log: name-default, legacy migration, reconciliation rename, malformed-marker and model-visible filtering assertions failed against previous behavior. Implementation then full70-test GREEN (hiding-first-green.log).
- Final `./scripts/test.sh`:70 tests, zero failures, TEST SUCCEEDED (42core/store,28app). Log Build/Evidence/hiding-final-tests.log; DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_1-24-20-+0300.xcresult. Additional automatic round-trip/rename and legacy hidden-true migration checks included before final run.
- Native signed final bundle copied to Build/HidingQA with isolated Temporary/HidingRuntimeQA. Grid146 visible entries after authorized defaults plus fixture. Search SK Launch Test produced1; right mouse context menu showed Hide Application; selecting it showed No Applications/0. Raw JSON retains fixture hidden=true, visibilityIsUserSet=true. Fixture execution proof timestamp remained13:07:37, so context action did not launch it. Native macOS Window sharing control still appears during capture; user confirmed icon, so no app titlebar changes selected.
- `SK_APP_MENU_SIGNING_IDENTITY=<installed fingerprint> ./scripts/package.sh 1.2.1-developer-id`: Release BUILD SUCCEEDED. App and DMG strict Developer ID signatures/timestamps verified; authority Siveesh Kodapully, teamMURZTM33SD, app Hardened Runtime. Not notarized. Raw logs Build/Evidence/hiding-package.log, hiding-dmg-*.log, hiding-installed-signature.log.
- DMG checksum VALID, SHA256d760b07b61150d5a814ab4211d1da360561f798b328e7796e88689ced585b7ad. Mounted read-only, old designated test app archived Build/Previous-1.2.0-build8, final packaged app copied to Build/Testing/SK's App Menu.app; deep strict signature passed, mount detached. Installed1.2.1/9 process25569 at exact testing executable without args observed.
- Actual normal-store before/after comparison:149 identical app UUIDs and category choices; all presentation settings equal. Only three requested default visibility changes: Creative Cloud Uninstaller, Uninstall, Uninstall Resolve (previously visible→hidden, automatic ownership). Existing already hidden Uninstall copy stays explicitly hidden. No QA manual fixture transferred. Original apps/storage otherwise unchanged; backup pipeline retained.
- Package staging removed by trap and DMG detached. Prior versions, current signed test app, isolated QA copy/store, logs/results intentionally retained; generated artifacts ignored by Git. Existing host simulator/autoShortcut/status-item/AppIntents and hdiutil-deprecation diagnostics remain nonblocking. No new entitlement/dependency or OS privacy/Dock/appearance changes. Structural checks recorded below after execution.

Final strict implementation, QA and documentation governance checks each passed with zero warnings; git diff --check passed. These structural checks supplement the functional/native/signature evidence above.

## 1.3.0 public release preparation —2026-11-14

- User authorized public GitHub source/DMG and Homebrew support, selected MIT and explicitly deferred notarization in favor of setup guidance. This release does not claim notarization or default-security first-download approval.
- Full ./scripts/test.sh:71 tests, zero failures (42core/store,29app), TEST SUCCEEDED. Log Build/Evidence/public-release-tests.log; result DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_1-44-50-+0300.xcresult. New integration proves Help menu action opens help scene and app-bundle resource exists. Root Help.md is one canonical source; old Resources duplicate removed and docs/Help.md becomes a link.
- Release build/signing successful; logs public-package-final.log, public-dmg-signature-final.log, public-installed-signature.log. App and DMG Authority Developer ID Application: Siveesh Kodapully (MURZTM33SD), secure timestamps; app Hardened Runtime, strict/deep signature verifies. No key export or notarization submission.
- Final DMG checksum VALID: Release/SKsAppMenu-1.3.0-arm64.dmg, SHA2567fba6495ce0ef214b2ec40dd4af69382713e3f8feb163ad35bb1622837c6decd. Mounted read-only and detached. Canonical root/app-resource/DMG Help.md bytes equal; INSTALL.md/LICENSE included; no test plugins. Installed1.3.0/10 process31274 at exact Build/Testing executable with no args observed. All149 normal UUID/hidden/category choices and appearance preferences compare equal; no SK Launch Test record.
- Native signed isolated Help window observed with complete guide content and Contents menu. Pointer/Capture state changes prevented dependable repeated Contents activation; do not claim complete visual interaction qualification. Guide paragraph/code styles compiled; menu/resource integration and byte comparison supply separate evidence.
- Persistent Temporary/LauncherFixture.app identified by own fixture bundle ID, unregistered via lsregister(exit0), deleted. Stale QA catalogs/fixture source/proof removed. After final validation,32 superseded generated items including previous test apps/QA copies/old DMGs removed (~71.9MiB); current app/DMG/source/normal settings/evidence retained. Log public-cleanup.log. No unrelated app, user settings/backup or original media deleted.
- Homebrew7.0.13 standalone cask style rejected because definitions must reside in a tap; real owner tap created, style passes(no offenses). Parsed info works after scoped trust of reviewed cask; no broad tap trust. Cask arm64/macOS27 dependency and final checksum mirror source. Logs public-tap-style-final.log/public-cask-info-final.json. No install/Gatekeeper/upstream acceptance claim from style/parse alone.
- Public tree common secret-pattern inspection clear; generated apps, DMGs and catalogs remain ignored. Actual clean-machine Gatekeeper qualification remains unestablished and notarization ticket validation is absent. Detailed local host diagnostics stay in ignored evidence, not uploaded. Remote publication/download/checksum/livecheck/audit evidence follows after execution.

## GitHub publication access check —2026-11-14

The signed-in owner browser session created the public empty repositories `siveesh/sks-app-menu` and `siveesh/homebrew-tap`. No source, tags or release assets have been uploaded yet. Existing GitHub CLI credentials deny source push (HTTP403), the connected GitHub integration denies blob writes (HTTP403), and the existing SSH configuration has no accepted key. Requested the owner update the existing fine-grained CLI token for only these two repositories with Contents and Workflows write access. No token/password/key was requested in chat, exported or changed by the agent. Publication/download/CI qualification remains pending that access.

## Published release verification —2026-11-14

- Owner saved a replacement CLI credential to Keychain; `gh auth status` confirms siveesh/keyring. Source push and owner-tap push succeeded without exporting or printing credentials. The earlier publication-access block is resolved.
- Public MIT repositories: [source](https://github.com/siveesh/sks-app-menu) and [owner tap](https://github.com/siveesh/homebrew-tap), both default branch main. Source release commit73f4ac82715ed5c98affaf4fdc4b6cc4025dd698; annotated v1.3.0 tag b53a1db50dcd2b511f1e339a09a85b191ee4b469 resolves to that commit. Tap cask commit a5aaf6b630c978e4c384f7aad0b5bc487c056092. Subsequent documentation evidence commits do not change the tagged binary.
- [Release v1.3.0](https://github.com/siveesh/sks-app-menu/releases/tag/v1.3.0) is published, latest, neither draft nor prerelease. All five assets are uploaded: DMG, SHA256SUMS.txt, Help.md, INSTALL.md and LICENSE. API evidence in ignored Build/Evidence/public-github-release.json and public-latest-release.json.
- Anonymous HTTPS download of the actual public DMG succeeded; SHA256 `7fba6495ce0ef214b2ec40dd4af69382713e3f8feb163ad35bb1622837c6decd` equals the original signed DMG, release asset digest and cask pin. Homebrew `fetch --cask siveesh/tap/sks-app-menu` exits0 and verifies the public artifact. The redundant temporary verification download was removed afterward; current release retained.
- Homebrew `livecheck --cask` exits0:1.3.0 ==>1.3.0. Real-tap style/parse checks previously passed, and [tap main style CI](https://github.com/siveesh/homebrew-tap/actions/runs/43590933909) passes. Online new-cask audit exits1 solely with repository notability error (<30 forks, <30 watchers and <75 stars); it also emits an external rubocop-md obsolete-configuration warning. Logs public-cask-fetch.log, public-cask-livecheck.log and public-cask-audit.log. No Homebrew installation or clean-machine Gatekeeper approval inferred.
- [Main governance CI](https://github.com/siveesh/sks-app-menu/actions/runs/43590923058) and [tag governance CI](https://github.com/siveesh/sks-app-menu/actions/runs/43590942180) pass. Native71-test result remains the locally recorded release qualification; the manual native workflow was not dispatched and no hosted native-test pass is claimed.
- Official Homebrew submission deferred: actual notability audit failure, new-repository age and unresolved clean default-security qualification. Owner tap is available. Notarization remains explicitly deferred; no security bypass or credential submission performed.
