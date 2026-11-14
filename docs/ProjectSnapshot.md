# Project Snapshot

- **Date:** 2026-11-14
- **Product:** SK's App Menu 1.0.3 (5), com.siveesh.sksappmenu
- **Branch:** feature/native-rebuild
- **Phase:** Implementation complete; automated QA and documentation handoff complete with listed manual/public-release follow-ups.
- **Build:** Debug and Release succeeded, Xcode27.2/Swift6.4.2 on macOS27.2.1.
- **Tests:**1.0.2 full baseline37 passed;1.0.3 focused menu regression passed.
- **Running local test app:** Build/Testing/SK's App Menu.app
- **DMG:** Release/SKsAppMenu-1.0.3-local.dmg (ad-hoc/runtime, not notarized)

Recursive real vendor discovery verified. Native management supports manual selection, hide/restore, categories, missing-app Locate and recovery. User requested icons and narrower menu; implemented in current build. Original launcher untouched. Preview preferences preserved to normal local storage. Next: user acceptance; remaining manual qualification and optional public signing/licensing.

Latest correction: application menu rows explicitly set preferredImageVisibility=.visible for macOS27. All utility scenes disable restoration. The final test copy was relaunched normally with no --manage flag (PID9097 observed at the Build/Testing executable path). Previous local test app retained at Build/Previous-1.0.0; settings untouched. Native windowless utility has no selectable CUA window surface; no new screenshot-based icon claim is made.37 automated tests and Release/package verification pass.

Next feature status: Dock launcher design/feasibility proposed, user chose categorized window. Detailed approval pending. No source/build/product changes for this feature. Current verified app remains1.0.2.

Latest scanner milestone: confirmed iOS wrappers shown in iOS Apps,149 installed apps/one unrelated native warning; hidden/category preferences preserved across upgrade. New default applies without rewriting existing overrides. Dock launcher design is still pending approval; no Dock production code added.

Final deployment evidence for1.0.2(4): Release build passed; final local DMG checksum verified, mounted read-only, copied to Build/Testing, strict codesign verification passed and DMG detached. App version/build read back as1.0.2/4, process12766 observed at the testing executable with no launch arguments. Saved catalog contains five iOS Apps records, and every previously saved visibility/category choice compared equal before/after upgrade. Settings were not reset or replaced. Previous local test build retained in Build/Previous-1.0.2-build3, previous1.0.1 in Build/Previous-1.0.1. Staging directories removed by package trap. All packages remain local ad-hoc/runtime builds, not notarized.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

1.0.3(5) deployment verified: Release BUILD SUCCEEDED; local DMG checksum valid; strict packaged-app signature verification passed. Mounted image copied to Build/Testing, detached, and normal menu-only launch observed as process13554; Info.plist reports1.0.3. Previous test app retained in Build/Previous-1.0.2-build4. No preference reset. Raw logs retained in Build/Evidence/sks-103-*.log. Category tooltips removed by source inspection; focused menu regression passes. Full37-test baseline remains1.0.2, not rerun for this styling-only change.
