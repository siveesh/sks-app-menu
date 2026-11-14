# Changelog

All notable project changes are documented here.

## Unreleased

- Project initialized from SK Project Template.


## 2026-11-14 — Project kickoff

- Initialized Application Menu governance from SK Project Template.
- Recorded requested launcher behavior and local toolchain evidence.
- Architecture and feasibility approval pending.

## 2026-11-14 — Native rebuild design

- Renamed product metadata to SK's App Menu; provisional bundle identifier com.siveesh.sksappmenu.
- Recorded user selection of native rebuild and proposed detailed architecture/feasibility.
- Defined nested discovery, app identity, manual add, visibility/category persistence, recovery, and acceptance criteria.
- Updated project overview, roadmap, QA plan, open issues, and verification/handoff records. No app implementation yet.

## 1.0.0 (1) —2026-11-14

- Built native SK's App Menu for macOS27+/Apple silicon with Swift6.
- Added recursive vendor-folder discovery, manual Browse/Add, reversible hiding, custom/persistent category controls and missing-app Locate.
- Added protected local settings, backups/recovery, serial saves and cancellation-safe scans.
- Added app icons in category menus, compact labels/full tooltips, native shortcuts and full-height management layout.
- Added Help/About, original layered icon, checked-in Xcode targets, tests and run/package tooling.
-31 tests pass; Debug/Release build, actual vendor scan and exact-URL launch verified. Local ad-hoc/runtime DMG only; public signing/notarization not claimed.

##1.0.1 (2) —2026-11-14

- Explicitly request visible app menu images using the macOS27 API.
- Disable utility-window restoration; normal launch stays in the menu bar.
- Add actual menu-row visibility regression;32 tests pass.

## Unreleased — Dock design proposal

- Drafted optional same-app Dock launcher with shared catalog and Compact/Comfortable/Spacious layouts. Categorized window selected by user; detailed architecture/feasibility approval pending. No product code changed.

##1.0.2 (4) —2026-11-14

- Recognize wrapped and flat iOS application layouts on Apple silicon; list them in iOS Apps.
- Preserve outer launch/icon identity, visibility and category overrides; keep genuine validation warnings.
- Preserve legacy custom categories already named iOS Apps.
- Add five compatibility tests;37 total pass. Refresh bundled Help. Dock feature remains pending design approval.
