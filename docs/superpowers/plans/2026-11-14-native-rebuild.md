# SK's App Menu Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for integration and isolated specialist tasks for core/UI work. Follow the approved architecture and record evidence.

**Goal:** Deliver the native categorized launcher with recursive discovery and durable user controls.
**Architecture:** Pure value catalog/discovery core, serialized persistence, MainActor model, native AppKit menus and SwiftUI management scenes.
**Tech Stack:** macOS 27+, Swift 6.4.2/Swift 6, SwiftUI, AppKit, Foundation, XCTest.
**Spec:** docs/Architecture.md and docs/Feasibility.md, approved 2026-11-14.

## Global Constraints

- Display name SK's App Menu; bundle com.siveesh.sksappmenu; internal target SKsAppMenu.
- macOS 27.0+, Apple silicon; no third-party runtime dependencies.
- Never modify installed apps or original launcher; local preferences only.
- No implementation approval prompts remain: user approved and instructed proceed.
- Work on feature/native-rebuild in current workspace. No merge or push implied.

## Review Focus

- Partial scans must preserve prior entries and edits.
- Duplicate bundle IDs at distinct locations must stay independent.
- Corrupt/newer stores must never be silently replaced with defaults.
- Canceled/old scans and saves must not undo later edits.
- Hidden apps must stay accessible to restore, including after relaunch.

## File map and interfaces

Sources/Core: CatalogTypes.swift, CategoryResolver.swift, DiscoveryService.swift, CatalogReconciler.swift, PreferencesStore.swift.
Sources/App: SKsAppMenuApp.swift, CatalogModel.swift, MenuController.swift, ManagementView.swift, CategoryManagementView.swift, AboutView.swift, HelpView.swift.
Tests/CoreTests: discovery, reconciliation, persistence and category tests. Resources: Info.plist, Assets.xcassets, AppIcon.icon, Help.md. scripts and script: build/test/package/run entrypoints. Xcode project contains MenuCore library, SKsAppMenu app, MenuCoreTests.

Shared core contract (all Sendable/Codable values where persisted):
- Availability: available, missing, unverified.
- AppRecord: id UUID, url URL, name String, bundleIdentifier String?, version String, automaticCategory String, bookmark Data?, fileIdentifier String?, isManual Bool, hidden Bool, categoryOverride String?, availability Availability.
- DiscoveredApp: url, name, bundleIdentifier, version, automaticCategory, bookmark, fileIdentifier; isManual Bool.
- AppCategory: id String, name String, isBuiltIn Bool. Built-ins have stable IDs, custom IDs are UUID strings.
- CatalogDocument: schemaVersion Int=1, apps [AppRecord], categories [AppCategory] (custom only).
- ScanResult: apps [DiscoveredApp], failedRoots [URL], warnings [String].
- DiscoveryService.scan(roots:[URL], manualURLs:[URL]=[], excluding:URL?=nil) throws -> ScanResult. Called outside MainActor.
- DiscoveryService.inspect(url:URL, allowBackground:Bool=false) throws -> DiscoveredApp.
- CatalogReconciler.merge(existing:[AppRecord], scan:ScanResult) -> [AppRecord].
- CategoryResolver.builtIn: [AppCategory], category(for metadata:String?) -> String; name(for id:String, custom:[AppCategory]) -> String.
- PreferencesStore actor init(directory:URL); load() throws -> CatalogDocument; save(_ document:CatalogDocument) throws; restoreBackup() throws; archiveAndReset() throws.

### Task 1: Discovery and catalog core

Files: Sources/Core/{CatalogTypes,CategoryResolver,DiscoveryService,CatalogReconciler}.swift; Tests/CoreTests/CoreTests.swift; Package.swift.
- [x] Write fixture tests for nested vendor bundles, package helpers, malformed apps, duplicate names/IDs, alias boundaries; run and observe missing-feature failure.
- [x] Implement contract above. Use real executable fixture files. Return partial failures. Reconcile identity/bookmarks/path before unique-ID relocation; preserve hidden/category/manual flags.
- [x] Run `swift test`, expected zero failures; record RED/GREEN and fixture performance.

### Task 2: Persistence and integration model

Files: Sources/Core/PreferencesStore.swift; Tests/CoreTests/PreferencesStoreTests.swift; Sources/App/CatalogModel.swift.
- [x] Test save/load preferences, backup, corrupt/newer files, invalid category references, failed writes, reset archive; observe missing-feature failure.
- [x] Implement bounded versioned atomic JSON with valid backup, read-only load failure, explicit recover/reset. Model serializes saves, coalesces refresh, merges latest preferences on scan completion, and reports unsaved changes.
- [x] Run core suite; expected zero failures. Test edits against in-flight snapshots through core reconciliation tests.

### Task 3: Native menu and management

Files: Sources/App app shell/menu/views; Resources/Help.md, About assets; Xcode project; run entrypoint.
- [x] Build core first, then implement native menu groups, icon cache, menu tracking deferral, exact-URL launch, picker/add/locate, management filters and category editing.
- [x] Create Xcode targets and build with Swift 6 and Hardened Runtime. Build/run via `script/build_and_run.sh --verify`.
- [x] Verify menu, add/cancel, hide/restore, category update/restart, Help/About, close and quit through UI; record actual outcomes.

### Task 4: Branding, QA, packaging and handoff

Files: Resources/AppIcon.icon and Assets.xcassets; scripts/package.sh; docs/*.md; README.md; CHANGELOG.md.
- [x] Create original layered Icon Composer assets and flattened export, verify compiler output and built icon.
- [x] Retrieve QA guidance, review code before fixes; independent whole-change review; fix important findings with targeted regression tests.
- [x] Run core suite, Xcode build/tests, runtime checks; measure fixture scan, menu build and idle behavior. Package a local DMG; label local/ad-hoc versus Developer ID/notarized accurately.
- [x] Retrieve documentation guidance; update all phase records, Help/build instructions, verification, issues, changelog and handoff. Invoke lessons bridge for genuine corrections.
- [x] Run strict governance verification, commit verified milestone on feature branch. No merge/push or overwrite installation.

## Self-review and rulings

Coverage: all Architecture behaviors mapped to tasks 1–4. Shared interfaces above are the integration boundary. Ruling: use the existing workspace on a feature branch instead of moving the user's active project; avoids extra workspace management, costs only loss of physical checkout isolation. Ruling: checked-in Xcode project may be generated using already-installed XcodeGen for reliable target setup; builds do not require the generator and no runtime dependency is added. Approval to proceed takes precedence over a second plan-approval cycle.

## Execution outcome

Local implementation complete;31 tests pass. Manual UI assessment is limited as recorded in Verification.md; public signing/notarization and earliest-OS/full VoiceOver qualification are follow-ups, not claimed completed. No merge/push performed.
