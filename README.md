# SK's App Menu

Native macOS menu-bar and optional Dock application launcher with recursive application discovery, manual addition, reversible hiding, and persistent category overrides.

## Requirements

macOS 27.0+ on Apple silicon. Development uses Xcode 27.2 / Apple Swift 6.4.2 in Swift 6 language mode. The development host runs macOS 27.2.1; macOS 27.0 runtime coverage remains a release qualification item.

## Build and run

Open `SKsAppMenu.xcodeproj` and select the SKsAppMenu scheme, or run:

```bash
./script/build_and_run.sh --verify
```

The script stops only the running SKsAppMenu process, builds Debug into DerivedData, and opens the app bundle. The Run button in Codex uses the same script. Options: --debug, --logs, --telemetry, --verify. The normal no-flag invocation builds and opens the app. `--telemetry` streams local process logs; there is no online analytics.

The checked-in Xcode project needs no generator to build. To regenerate after adding source files, use the already-installed XcodeGen with `xcodegen generate` and keep `project.yml` in sync. No third-party runtime packages are used.

## Tests

```bash
swift test
./scripts/test.sh
/usr/bin/python3 scripts/verify_governance.py --strict --phase documentation
```

SwiftPM covers MenuCore. Xcode additionally runs hosted app-model tests; its scheme sets an isolated `Temporary/XcodeTestStore` directory. Do not run both Xcode test/build commands against the same DerivedData directory concurrently. The default Python shim on this development machine is broken; the governance hook explicitly uses `/usr/bin/python3`.

## Use

Click the grid icon in the menu bar. Apps are grouped by category, with names and icons. Choose Manage Applications to browse/search, toggle visibility, pick another category, or locate a missing app. Add Application opens the standard picker. Custom categories can be created, renamed, and deleted from Categories. Refresh scans nested ordinary folders under /Applications, /System/Applications and ~/Applications. Helper apps inside app bundles and linked directories are excluded. Manual selection handles apps elsewhere.

[Detailed Help](docs/Help.md) is also bundled and accessible from the app's Help menu. About uses the existing SK developer identity assets and an original layered app icon.

Choose **Show in Dock** to enable the categorized icon grid. **Open Launcher…** also opens it without a Dock icon. Compact, Comfortable, and Spacious change icon, text, and grid tile sizes; your choice is saved. The window shares search, categories, visibility, and exact-copy launching with the menu. Clicking the Dock icon restores the same window. The original Prism Launcher icon uses native Icon Composer layers and supports Default, Dark, and Mono appearances.

**Hide Refresh Warnings** in the menu or Manage Applications suppresses scan notices in both launchers and remembers your choice. Details remain available in Manage Applications; clear the option to restore notices. The launcher banner also has a Hide button.

## Settings and recovery

Settings live in `~/Library/Application Support/com.siveesh.sksappmenu/catalog.json`; the previous valid state is in `catalog-backup.json`. Hiding changes only this launcher. Installed bundles are never edited or removed. Unknown/missing automatic categories use Other until overridden. Duplicate installed copies remain independent.

A damaged/newer catalog is protected in read-only mode. Manage Applications offers Restore Backup or an explicit Archive and Reset action. Save failures remain visible with retry. Quit waits for pending saves, then asks before discarding unsaved work if necessary.

For isolated QA, launch the app with `--manage --store-directory /absolute/test/directory` or set `SK_APP_MENU_STORE_DIRECTORY`. `--manage` opens the management window after startup. Normal startup stays in the menu bar unless Show in Dock was enabled; then the launcher opens. Manage Applications never opens automatically. Closing a window does not quit the app.

## Local packaging

```bash
SK_APP_MENU_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/package.sh 1.2.0-developer-id
```

Creates a Release-configuration DMG in Release with the app, Applications link and installation notes. It refuses to overwrite an existing same-version artifact. Without SK_APP_MENU_SIGNING_IDENTITY the script produces an ad-hoc local build. With the explicitly supplied Developer ID it signs both the app (Hardened Runtime and secure timestamp) and DMG. Version1.2.0 was signed with the owner's Developer ID Application certificate after explicit authorization. **Neither mode performs notarization.** Gatekeeper may block an ad-hoc download; do not disable system security. Public distribution requires signing/notarization and a repository licence decision.

## Repository and records

Sources/Core contains values, discovery, classification, reconciliation and persistence. Sources/App contains the MainActor model, SwiftUI windows and isolated AppKit menu bridge. Resources contains Info.plist, user help, About assets and layered AppIcon.icon. Tests covers the core and app model. scripts/ and script/ hold tooling.

[Architecture](docs/Architecture.md) and [Feasibility](docs/Feasibility.md) were approved by Siveesh on 2026-11-14. [Verification](docs/Verification.md), [QA](docs/QA.md), [Open issues](docs/OpenIssues.md), and [Handoff](docs/SessionHandoff.md) record actual evidence and remaining limitations. AGENTS.md is authoritative.

This is an independent rebuild using https://github.com/barseghyanartur/app-menu/ as a behavioral reference. No upstream code or assets were imported. No licence to third-party material is implied. Developer identity images were reused from the owner's Relay project; public repository licensing is not yet selected.

Version1.0.1 explicitly preserves application icons in macOS27 menus. Normal launch opens no utility windows; Manage Applications is opened from the menu when needed, and its window is not restored from the previous session.

Version1.0.2 recognizes installed iOS-on-Mac wrappers and flat iOS app bundles in iOS Apps. Genuine inaccessible/invalid bundles still warn. Existing custom categories and per-app overrides are preserved.

Codex test relaunches explicitly target the built application using open -a, wait for the previous process to stop and verify the executable before launch. Native UI QA uses an already-running signed copy at a stable path to avoid launching through ambiguous cached bundle registrations. Debug/test hosts remain locally signed; the packaged app is Developer ID signed.
