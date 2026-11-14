# Dock presentation core implementation

Date: 2026-11-14. Scope: Task 1 of the approved Dock launcher plan. This report covers the shared core and SwiftPM suite only; it does not establish app lifecycle, UI, packaging, installation or release acceptance.

## Changes

- Added public `LauncherDensity` (`compact`, `comfortable`, `spacious`), titles, stable identifiers and approved icon/row/font dimensions.
- Added `PresentationPreferences`, defaulting Dock presence off and density to Comfortable.
- Added `CatalogDocument.presentation` with a default initializer argument and custom backward-compatible decoder. Existing schema/apps/categories fields remain required and strictly decoded. Synthesized encoding writes the full presentation block.
- Retained schema version 1 and the existing `PreferencesStore` atomic/backup/recovery implementation unchanged.

## Compatibility and protection

Missing/null presentation blocks and missing/null individual settings use safe defaults. Unknown string density values map to Comfortable without dropping the Dock choice. Non-string density, non-Boolean Dock values and non-object presentation blocks fail decoding. The real protected store test confirms malformed presentation cannot be overwritten and does not create a misleading backup.

The literal old schema-1 fixture verifies every AppRecord field, UUID, hidden choice, custom category/override, bookmark and metadata survives decode and round-trip. Required schemaVersion/apps/categories remain strict, including missing/null/wrong-type fields and incomplete records. Real-store tests reopen each density and restore an old-format backup with all records intact.

An older binary can still read schema-1 catalog records, but may discard the optional new presentation block when it saves; this is the approved compatibility limitation. Scan/model preservation must be verified by the app task, since it reconstructs catalog snapshots.

## Test evidence

1. RED: `swift test --filter PresentationPreferencesTests`, exit 1, 2026-11-14 12:21:30 local. Three compiled behavioral tests executed with ten expected assertion failures: old encoding omitted the block and old decoding ignored malformed presentation values. Log: `Build/Evidence/dock-core-red.log`.
2. GREEN: `swift test`, exit 0, 2026-11-14 12:22:54 local. All 37 SwiftPM XCTest tests passed with zero failures, including ten new presentation tests. Log: `Build/Evidence/dock-core-green.log`. Swift Testing's separate zero-test line is not the XCTest count.
3. `git diff --check` exited 0 after the core edits. No compiler warnings appeared in the SwiftPM log.

New tests: legacy decode/defaults and complete record retention; partial/null defaults; unknown-string fallback/type rejection; complete presentation encoding; malformed block/value rejection; every-density persistence; old-backup recovery; malformed-file save protection; required-field strictness.

## Governance and handoff

Read AGENTS.md, required project records, approved Dock design and shared-contract plan. Used orchestrator implementation/QA/documentation retrieval and TDD. Default `python3` points to a broken pyenv shim; `/usr/bin/python3` works, matching the existing handoff workaround. macOS retrieval returned irrelevant agent-tool guidance; no new Apple API or unsupported assertion was adopted. The change uses existing Foundation/Codable behavior only.

Lessons workflow reviewed: no new implementation mistake or reusable correction identified in this task; no invented lesson recorded. Root owns phase-level records, strict governance verification and integration. Core-owned files: `Sources/Core/PresentationPreferences.swift`, `Sources/Core/CatalogTypes.swift`, `Tests/CoreTests/PresentationPreferencesTests.swift`, and this report. No commits, production-store changes, install, cleanup or app build were performed by this task.
