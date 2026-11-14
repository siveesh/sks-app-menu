# Session Handoff

Updated2026-11-14. Product SK's App Menu1.0.2(4). Branch feature/native-rebuild. No merge/push.

## Completed

Architecture/Feasibility explicitly approved by user, then native rebuild implemented. Core recursive discovery finds real Photoshop2027 and DaVinci Resolve nested apps. Management includes manual add, hide/restore, persistent/custom categories, missing-app Locate and recovery. Native menu has app icons installed before layout, concise labels, bounded long names/full tooltips and shortcuts, per user's refinement.37 tests pass; Release local DMG created/verified and running local test installation.

## Artifacts and commands

- Build/Testing/SK's App Menu.app — current running Release-based local test app, copied from DMG.
- Release/SKsAppMenu-1.0.2-local.dmg — checksum verified; ad-hoc/runtime signed, not notarized.
- Build/Evidence — retained raw logs; Verification.md documents actual evidence.
- `./script/build_and_run.sh --verify` — canonical Debug build/run.
- `./scripts/test.sh` — Xcode full suite; `swift test` — core only.
- `./scripts/package.sh <new-artifact-version>` — refuses same-version overwrite.

## Preferences and recoverability

Normal storage ~/Library/Application Support/com.siveesh.sksappmenu. Preview RuntimeQA settings were copied only because normal catalog did not yet exist, preserving one hidden app and one category override. No existing user catalog was overwritten. Original launcher/apps untouched. Package staging cleaned, DMG detached; QA settings and evidence retained intentionally. Use /usr/bin/python3 for governance because default pyenv shim is broken.

## Remaining work

User acceptance, full VoiceOver/light-mode/pointer/Help/About manual qualification, macOS27.0 runtime testing, public licence selection and optional Developer ID/notarization. Do not claim public-distribution eligibility from ad-hoc verification. No production signing credentials inspected or provisioned. Existing native-control session had external-state invalidations; its incomplete picker round-trip is not a product failure claim.

## Lessons and decisions

Recorded genuine issues: cancellation boundaries, root bundle traversal, unique unmatched relocation, current Apple category identifiers, static-core hosted-test linkage, stale Add/Locate snapshots, settings recovery state, and generated-artifact governance false positives. See ImplementationLedger.md, CoreImplementationReport.md, UIImplementationReport.md and global lessons. Current workspace retained on feature branch; checked-in generated Xcode project builds without XcodeGen dependency at build time.

Latest correction: application menu rows explicitly set preferredImageVisibility=.visible for macOS27. All utility scenes disable restoration. The final test copy was relaunched normally with no --manage flag (PID9097 observed at the Build/Testing executable path). Previous local test app retained at Build/Previous-1.0.0; settings untouched. Native windowless utility has no selectable CUA window surface; no new screenshot-based icon claim is made.37 automated tests and Release/package verification pass.

## Current next milestone: Dock launcher design

User selected categorized launcher window over menu-style popup. Review docs/superpowers/specs/2026-11-14-dock-launcher-design.md and the Architecture/Feasibility addenda. Proposed same-app optional Dock (default off), shared preferences/catalog and three density presets. Await explicit detailed design approval before production code. Existing1.0.2 app/package unchanged and still the current verified build. Next after approval: writing-plans, implementation-specific macOS retrieval, then code/test/runtime/package. No genuine lesson to add during this design-only phase.

Latest scanner milestone: confirmed iOS wrappers shown in iOS Apps,149 installed apps/one unrelated native warning; hidden/category preferences preserved across upgrade. New default applies without rewriting existing overrides. Dock launcher design is still pending approval; no Dock production code added.

Final deployment evidence for1.0.2(4): Release build passed; final local DMG checksum verified, mounted read-only, copied to Build/Testing, strict codesign verification passed and DMG detached. App version/build read back as1.0.2/4, process12766 observed at the testing executable with no launch arguments. Saved catalog contains five iOS Apps records, and every previously saved visibility/category choice compared equal before/after upgrade. Settings were not reset or replaced. Previous local test build retained in Build/Previous-1.0.2-build3, previous1.0.1 in Build/Previous-1.0.1. Staging directories removed by package trap. All packages remain local ad-hoc/runtime builds, not notarized.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

1.0.3(5) deployment verified: Release BUILD SUCCEEDED; local DMG checksum valid; strict packaged-app signature verification passed. Mounted image copied to Build/Testing, detached, and normal menu-only launch observed as process13554; Info.plist reports1.0.3. Previous test app retained in Build/Previous-1.0.2-build4. No preference reset. Raw logs retained in Build/Evidence/sks-103-*.log. Category tooltips removed by source inspection; focused menu regression passes. Full37-test baseline remains1.0.2, not rerun for this styling-only change.
