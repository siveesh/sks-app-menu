# Grid launcher and signed package implementation plan

Goal: replace Dock rows with responsive icon tiles, use the owner's approved Developer ID for packaging and investigate macOS popup during Codex test relaunches.

- [x] Add focused navigation/layout boundary tests; implement native lazy grid with category/search/empty-state, all three sizes, arrow/Return selection and exact URL actions. No new presentation storage.
- [x] Trace launch-warning context read-only, reproduce before a source fix; distinguish tooling/OS from catalog scan errors. Retain evidence and describe unresolved limitations.
- [x] Add explicit package signing identity support and truthful readme for Developer ID versus ad-hoc. Validate actual signature/team/timestamp; no notarization claim.
- [x] Run final full suite, native grid/density/search/keyboard/relaunch QA, Release build, signed DMG verification, preserve prior test app and user choices. Document all phases, actual lessons and handoff; strict governance and commit on current branch.
