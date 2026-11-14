# SK's App Menu

Native macOS menu-bar application launcher with recursive application discovery, manual addition, reversible hiding, and persistent category overrides.

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

## Settings and recovery

Settings live in `~/Library/Application Support/com.siveesh.sksappmenu/catalog.json`; the previous valid state is in `catalog-backup.json`. Hiding changes only this launcher. Installed bundles are never edited or removed. Unknown/missing automatic categories use Other until overridden. Duplicate installed copies remain independent.

A damaged/newer catalog is protected in read-only mode. Manage Applications offers Restore Backup or an explicit Archive and Reset action. Save failures remain visible with retry. Quit waits for pending saves, then asks before discarding unsaved work if necessary.

For isolated QA, launch the app with `--manage --store-directory /absolute/test/directory` or set `SK_APP_MENU_STORE_DIRECTORY`. `--manage` opens the management window after startup. Normal startup stays in the menu bar. Closing a window does not quit the app.

## Local packaging

```bash
./scripts/package.sh 1.0.1-local
```

Creates a Release-configuration DMG in Release with the app, Applications link and installation notes. It refuses to overwrite an existing same-version artifact. This script produces an **ad-hoc signed local development build**, with Hardened Runtime, **not a Developer ID signed or notarized public release**. Gatekeeper may block an ad-hoc download; do not disable system security. Public distribution requires signing/notarization and a repository licence decision.

## Repository and records

Sources/Core contains values, discovery, classification, reconciliation and persistence. Sources/App contains the MainActor model, SwiftUI windows and isolated AppKit menu bridge. Resources contains Info.plist, user help, About assets and layered AppIcon.icon. Tests covers the core and app model. scripts/ and script/ hold tooling.

[Architecture](docs/Architecture.md) and [Feasibility](docs/Feasibility.md) were approved by Siveesh on 2026-11-14. [Verification](docs/Verification.md), [QA](docs/QA.md), [Open issues](docs/OpenIssues.md), and [Handoff](docs/SessionHandoff.md) record actual evidence and remaining limitations. AGENTS.md is authoritative.

This is an independent rebuild using https://github.com/barseghyanartur/app-menu/ as a behavioral reference. No upstream code or assets were imported. No licence to third-party material is implied. Developer identity images were reused from the owner's Relay project; public repository licensing is not yet selected.

Version1.0.1 explicitly preserves application icons in macOS27 menus. Normal launch opens no utility windows; Manage Applications is opened from the menu when needed, and its window is not restored from the previous session.
