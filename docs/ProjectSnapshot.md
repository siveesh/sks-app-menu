# Project Snapshot

- **Date:** 2026-11-14
- **Product:** SK's App Menu 1.0.1 (2), com.siveesh.sksappmenu
- **Branch:** feature/native-rebuild
- **Phase:** Implementation complete; automated QA and documentation handoff complete with listed manual/public-release follow-ups.
- **Build:** Debug and Release succeeded, Xcode27.2/Swift6.4.2 on macOS27.2.1.
- **Tests:**32 passed, zero failures.
- **Running local test app:** Build/Testing/SK's App Menu.app
- **DMG:** Release/SKsAppMenu-1.0.1-local.dmg (ad-hoc/runtime, not notarized)

Recursive real vendor discovery verified. Native management supports manual selection, hide/restore, categories, missing-app Locate and recovery. User requested icons and narrower menu; implemented in current build. Original launcher untouched. Preview preferences preserved to normal local storage. Next: user acceptance; remaining manual qualification and optional public signing/licensing.

Latest correction: application menu rows explicitly set preferredImageVisibility=.visible for macOS27. All utility scenes disable restoration. The final test copy was relaunched normally with no --manage flag (PID9097 observed at the Build/Testing executable path). Previous local test app retained at Build/Previous-1.0.0; settings untouched. Native windowless utility has no selectable CUA window surface; no new screenshot-based icon claim is made.32 automated tests and Release/package verification pass.
