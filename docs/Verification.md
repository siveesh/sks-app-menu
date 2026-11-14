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
