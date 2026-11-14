# Dock launcher implementation plan

> **For agentic workers:** Use focused specialist tasks plus root integration and independent review. Approved design is binding; proceed without another approval cycle.

**Goal:** Optional same-app Dock launcher with three densities and original layered icon.
**Architecture:** Shared catalog/model, backward-compatible presentation settings, native SwiftUI singleton window and narrow AppKit activation/reopen controller.
**Tech stack:** macOS27+, Swift6, SwiftUI/AppKit/Foundation, Icon Composer, no runtime packages.
**Spec:** docs/superpowers/specs/2026-11-14-dock-launcher-design.md (approved2026-11-14).

## Global constraints

- Preserve com.siveesh.sksappmenu and all app UUIDs, categories, hidden flags, metadata validation and safe recovery.
- Dock default off; Comfortable default. Never open Manage Applications automatically.
- Compact20/32/13pt icon/row/text; Comfortable28/44/14; Spacious40/60/16.
- Remain on existing feature/native-rebuild branch, retain workspace; no merge/push or system Dock preference edits.
- Native menus retain visible icons and no category hover tooltips.

## Review focus

- Old schema1 files lacking presentation must retain every old record.
- Unknown density must gracefully use Comfortable; malformed protected data must never be overwritten.
- Dock activation failure must not falsely save enabled state.
- Reopen/minimized window and delayed SwiftUI relay must never create duplicate windows or open management.
- Scans, recovery and suspended saves must preserve latest presentation edits.

## Shared core contract

Create Sources/Core/PresentationPreferences.swift. Public LauncherDensity:String, CaseIterable, Codable, Sendable, Identifiable (.compact,.comfortable,.spacious), id Self; title:String; iconSize,rowHeight,fontSize:Double. Unknown decoded string -> Comfortable. Public PresentationPreferences:Codable,Sendable,Equatable with showInDock:Bool=false and launcherDensity:LauncherDensity=.comfortable plus public defaulted init. Missing individual keys use defaults; malformed non-string/bool types fail rather than silently erase unrelated data.

CatalogDocument adds public var presentation:PresentationPreferences with defaulted initializer argument. Custom decoder reads missing/null presentation as default while required existing schema/apps/categories decoding stays strict; encoder writes full block. Do not change schemaVersion1. PreferencesStore's existing atomic/backup/recovery pipeline stores the new values without a separate store.

### Task1: Presentation core

Files: Sources/Core/PresentationPreferences.swift, CatalogTypes.swift; Tests/CoreTests/PresentationPreferencesTests.swift.
- [x] Write old schema/new density/unknown-density/persistence tests, observe RED.
- [x] Implement the shared contract and round-trip without changing app IDs/hidden/overrides.
- [x] Run swift test suite, expected zero failures; record precise evidence.

### Task2: Native launcher and Dock lifecycle

Files: Sources/App/LauncherView.swift (split subviews as needed), DockPresenceController.swift, CatalogModel.swift, SKsAppMenuApp.swift, MenuController.swift, ManagementView.swift; Tests/AppTests/DockLauncherTests.swift.
- [x] Test model edits/durability, scan-preserved presentation, failed activation, startup/reopen/queued relay routing; observe RED for meaningful behavior.
- [x] Implement native category sidebar and visible app list, search in selected category, icon/text/spacing density picker, exact-URL launching, keyboard/Return, full-path tooltips and errors.
- [x] Add Open Launcher and Show in Dock menu controls; Appearance controls in Manage. Activation policy changes on MainActor, validate result, roll back failed transition; save through existing model revisions. Recovery applies loaded preference safely.
- [x] Native singleton Window launcher remains default-suppressed/nonrestoring; explicit open after successful Dock startup/enabling and on Dock reopen. Restore minimized launcher through a narrow existing-window bridge; delayed relay queues one open. Disabling Dock closes launcher; menu remains accessible. Closing window keeps app alive.
- [x] Build and run full Xcode tests under isolated test-store environment; report results without concurrent DerivedData access.

### Task3: Icon and branding

Files: Resources/AppIcon.icon layered SVG/JSON, Resources/Branding previews, AboutView.swift if needed to present app icon.
- [x] Create a distinct original launch/navigation mark with layered translucent forms, dark-adaptive contrast, clean silhouette at small sizes.
- [x] Compile with native actool, inspect default/dark/mono previews and flattened export. No code-generated fake glass in user flows.
- [x] Preserve source assets; app build/package must compile the icon and use it for Dock/Finder/About.

### Task4: Integration, QA and handoff

Files: project.yml/Xcode project, Resources/Help.md, docs/*.md, README/CHANGELOG.
- [x] Independent review of contracts/failure cases; fix Important findings with regressions.
- [x] Final full suite, Debug/Release builds, isolated runtime all three densities/Dock enable-disable/reopen/minimize/no-management startup; verify saved settings and older records.
- [x] Capture evidence, package new local DMG, verify checksum/signature, archive previous designated test app and launch latest without forcing Dock on or resetting preferences.
- [x] Update phase records, lessons for actual corrections, handoff and strict verification; commit milestone on existing branch.

## Preflight / rulings

Tasks1 and2 share only the fixed public presentation contract; Task3 owns resources independently. Root owns project generation/build lock, docs and final packaging. Source ownership avoids collisions. Approval to proceed supersedes another plan-approval prompt. Native icon assets are repo-native vector layers rather than an external raster/marketing-board workflow. Preserve working app while development runs in isolated test stores.
