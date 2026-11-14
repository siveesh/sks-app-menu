# Implementation ledger — plan: docs/superpowers/plans/2026-11-14-native-rebuild.md

Approvals: Architecture and Feasibility approved by Siveesh, 2026-11-14. Feature branch feature/native-rebuild; base e309266. Baseline: governance only, no app target/tests existed.
Rulings: current workspace feature branch; checked-in generated Xcode project; no repeat approval prompt (see plan).
Preflight: task 1 produces shared catalog interfaces used by tasks 2/3; exact contract fixed in plan. Task 2 store and model consumed by task 3 UI; model contract supplied before UI implementation. Task 4 covers integration QA and release limitations.

Task 2 persistence: missing PreferencesStore compile RED observed; six recovery/roundtrip/corruption/write-failure tests now GREEN. Raw logs /tmp/sks-store-red.log and /tmp/sks-store-final.log.
Correction: strict verifier initially scanned generated .build/XCBuildData JSON and incorrectly reported template markers. Reproduced with strict implementation verification. Skip known generated directories; retain checks on project source records.
Branding: original menu-panel SVG layers authored in Resources/AppIcon.icon, compiled by actool to AppIcon.icns and Assets.car; flattened export inspected. Relay About reference inspected; user-owned Logo1/Logo2 imagesets copied for consistent About identity. No upstream code/assets imported.
Task 1 implementation evidence: 22 SwiftPM tests, 0 failures (16 core + 6 persistence); 1,000-fixture scan 0.339s, warm merge 0.032s. Real installed scan:144 apps, 6 warnings,0 failed roots,.168s. Photoshop2027 and Resolve found within vendor subfolders.
Task 2 review: persistence store compliant; model external-corruption recovery transition identified and addressed with typed recovery state.
Task 3 integration: Debug app build succeeded. Hosted test target initially duplicated static MenuCore symbols; fixed app-test dependency link:false to use host's types. Dedicated test store env prevents host tests from writing ordinary user settings.
Whole-change review: two Important findings (manual Add/Locate versus stale scan; Locate into already-discovered ambiguous copy). Assigned regression fixes to UI implementer. No Critical finding; no merge/push or installed-app changes.

Task3: both Important review findings fixed RED→GREEN, plus stop/restart regression; full31-test Xcode suite passed. Actual launcher fixture URL proof normalized /var symlink spelling.
User refinement: app icons before submenu layout, concise status/actions, compact long titles with full tooltips and Add shortcut. Final suite passed on refinement source.
Task4: Release build+localDMG created, checksum and ad-hoc/runtime signature verified. Copied into Build/Testing and process at that exact path observed. Preview preferences preserved only into absent normal store. Public release qualifications remain explicit.
Phase lessons bridge invoked for real implementation/QA/documentation corrections; no invented lessons. Branch retained without merge/push as scoped.
