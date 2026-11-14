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

## Historical Dock design preparation

- Drafted optional same-app Dock launcher with shared catalog and Compact/Comfortable/Spacious layouts. Categorized window selected by user; detailed architecture/feasibility approval pending. No product code changed.

##1.0.2 (4) —2026-11-14

- Recognize wrapped and flat iOS application layouts on Apple silicon; list them in iOS Apps.
- Preserve outer launch/icon identity, visibility and category overrides; keep genuine validation warnings.
- Preserve legacy custom categories already named iOS Apps.
- Add five compatibility tests;37 total pass. Refresh bundled Help. Dock feature remains pending design approval.

##1.0.3 (5) —2026-11-14

- Remove distracting category hover tooltips in the menu bar; retain app name/path tooltips.

##1.1.0 (6) —2026-11-14

- Add optional Dock presence and a categorized launcher sharing the existing catalog, visibility, categories and exact-copy launching.
- Save Compact, Comfortable and Spacious display sizes; support category search, keyboard selection/Return and minimized-window restoration.
- Keep management opt-in; Open Launcher also works with Dock disabled. Handle delayed scene registration and failed activation policy changes safely.
- Add original Prism Launcher layered Liquid Glass icon with inspected Default/Dark/Mono appearances.
- Extend schema1 with an optional presentation block; older catalogs keep all app IDs and preferences. Unknown density strings fall back to Comfortable. No runtime dependencies added.
- Fix All Applications sidebar selection and minimized launch-error routing during QA.59 tests pass; local ad-hoc package only.

## 1.1.1 (7) —2026-11-14

- Add saved Hide Refresh Warnings option in the menu and Manage Applications, plus a launcher banner Hide button.
- Suppress scan notices in both launchers while preserving diagnostic details in management and keeping other error notices visible.
- Default older catalogs to showing warnings; preserve existing Dock/density/application preferences. No scanner, dependency or permission changes.
