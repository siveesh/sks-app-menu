# Native UI and Catalog Model Implementation

Date: 2026-11-14
Scope: Sources/App, Tests/AppTests, bundled Help and documentation Help.
Status: Debug app built; 30 Xcode tests passed. Interactive runtime acceptance is tracked separately by the integrating agent.

## Implemented behavior

The application uses NSStatusItem and native NSMenu category submenus, alphabetized by category and application. Its status icon exposes an accessibility label. The adapter defers rebuilding during menu tracking, installs cached icons before submenu layout after the user refinement, caches icons by location/version, and keeps Add, Manage, Refresh, About, Help and Quit available even with an empty or fully hidden catalog. Exact application URLs launch through asynchronous NSWorkspace APIs; failures surface in management.

SwiftUI singleton scenes own Manage Applications, Categories, Help and About. A small action relay forwards status-menu requests to SwiftUI's openWindow action. No manually created NSWindow is used. Normal operation is accessory/menu-bar only; closing utility windows does not quit. About follows the Relay reference with owner-provided Logo1/Logo2 assets and dark-mode inversion for Logo2.

Management offers search by name, path or category; All/Visible/Hidden/Missing filters; path and availability labels; detail controls for visibility, category overrides, Automatic category, opening, Finder reveal and locating missing apps. The native picker accepts application bundles, makes no change on cancel, selects existing duplicate records and preserves hidden state. Manual background application selection displays a notice. Custom categories support trimmed validated names, case-insensitive duplicate prevention, rename, confirmed deletion and Automatic fallback.

CatalogModel owns the current document on MainActor. PreferencesStore is injected behind an asynchronous persistence protocol. Loading failures preserve the store and disable edits. Confirmed backup recovery and archive/reset remain reachable. Invalid/newer saved data encountered during a write also transitions to recovery/read-only; ordinary save failures retain in-memory changes with a persistent Retry warning. Saves serialize by revision and loop until newer edits are persisted. Quit awaits pending saves and asks Cancel/Quit Without Saving if unsaved changes remain.

Scanning executes in a detached utility task. Refresh requests coalesce, generations reject stopped workers, and publication merges current preferences. Partial warnings remain visible. Ordinary manual bookmarks resolve off MainActor before scanning. Successful Add/Locate invalidates an older worker's manual URL list, cooperatively cancels it and queues a replacement after completion; it never starts overlapping scan workers. Locate can reconnect a missing UUID to an already discovered location, retaining missing-record preferences. Conflicting preferences on the duplicate require explicit confirmation.

Local QA can use --manage and --store-directory PATH, or SK_APP_MENU_STORE_DIRECTORY. These operational overrides isolate reversible runs from normal Application Support settings. There is no test-only production behavior flag or telemetry.

## Evidence

- xcodebuild -project SKsAppMenu.xcodeproj -scheme SKsAppMenu -destination 'platform=macOS' -derivedDataPath DerivedData build: BUILD SUCCEEDED. Log: /tmp/sks-app-menu-ui-build.log.
- Final xcodebuild test with the same project/scheme/destination/DerivedData: TEST SUCCEEDED; 22 core tests and eight model tests, zero failures. Log: /tmp/sks-app-menu-ui-tests.log. Result: DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_11-40-01-+0300.xcresult.
- Model cases cover failed-load protection, category validation/deletion, newest-edit persistence across an actually suspended save, finishSaving draining, recovery-required write failure, scan/edit races with refresh coalescing, Add versus stale scan and explicit Locate into a duplicate installed location, and stop/restart waiting for cooperative cancellation.
- The Add/Locate and stop/restart regressions first failed with the expected behavior: stale scan marked a newly added app missing; Locate left two rows and the old location. Stop/restart also demonstrated overlapping workers before its fix. All three passed after fixes. Other initial tests were authored before implementation but the initial standalone compiler attempt could not locate XCTest; no full TDD RED claim is made for those cases.
- A test-host double-link of static MenuCore caused duplicate runtime types and a false recovery-error type check. Integration changed the hosted test dependency to link:false; the duplicate warning disappeared and recovery assertions passed. A URL assertion was corrected to compare normalized paths because directory URL syntax can include a trailing slash.
- Xcode reports host CoreSimulator-version mismatch (macOS target unaffected) and skipped App Intents metadata extraction (no AppIntents dependency). These are environment/tooling messages, not product compatibility evidence.

## Limits of this report

This establishes compilation and automated core/model behavior on the development toolchain. It does not certify interactive menu timing, native keyboard behavior, VoiceOver, light/dark layout, picker cancellation, actual application launch, runtime macOS 27.0 compatibility, installation, Developer ID signing, notarization or release packaging. Those need separate recorded evidence. Local build signing is ad hoc; the build log states hardened runtime is disabled for that signing mode despite the project release intent.

## Latest layout delta

The integrating runtime check observed a management list compressed into the bottom portion of its window. Explicit vertical filling and top alignment were added to the management split view and its panes after the final test run above. This view-only delta awaits the integrating agent's next build and visual verification; the test/build product was frozen for ongoing UI control.

## Root integration follow-up

Vertical layout fix rebuilt and visually verified. Final suite now31 tests including actual exact-URL launch. User-requested app icons and compact menu labels/width implemented. Local packaged copy explicitly re-signed ad-hoc with runtime flag and verified; see Verification.md for distinction from plain Xcode signing.
