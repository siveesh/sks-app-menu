# Session Handoff

Updated2026-11-14. Product SK's App Menu1.0.1(2). Branch feature/native-rebuild. No merge/push.

## Completed

Architecture/Feasibility explicitly approved by user, then native rebuild implemented. Core recursive discovery finds real Photoshop2027 and DaVinci Resolve nested apps. Management includes manual add, hide/restore, persistent/custom categories, missing-app Locate and recovery. Native menu has app icons installed before layout, concise labels, bounded long names/full tooltips and shortcuts, per user's refinement.32 tests pass; Release local DMG created/verified and running local test installation.

## Artifacts and commands

- Build/Testing/SK's App Menu.app — current running Release-based local test app, copied from DMG.
- Release/SKsAppMenu-1.0.1-local.dmg — checksum verified; ad-hoc/runtime signed, not notarized.
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

Latest correction: application menu rows explicitly set preferredImageVisibility=.visible for macOS27. All utility scenes disable restoration. The final test copy was relaunched normally with no --manage flag (PID9097 observed at the Build/Testing executable path). Previous local test app retained at Build/Previous-1.0.0; settings untouched. Native windowless utility has no selectable CUA window surface; no new screenshot-based icon claim is made.32 automated tests and Release/package verification pass.
