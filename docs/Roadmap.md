# Roadmap

| Phase | Status | Evidence |
| --- | --- | --- |
|1 Architecture | Approved2026-11-14, including Dock addendum | Architecture.md and approved design |
|2 Feasibility | Approved2026-11-14 | Feasibility.md |
|3 Implementation | Complete1.3.0 | Shared presentation persistence, native Dock lifecycle/launcher, layered icon |
|4 QA & Performance |71 tests pass; native smoke complete | Verification.md, DockUIReport.md, DockCoreReport.md |
|5 Documentation | Complete; package/install/launch evidence recorded | Help, README, changelog, handoff |
|Public qualification | Pending | Notarization, licence, VoiceOver/light appearance, macOS27.0 runtime |

Delivered milestones: native rebuild1.0.0, menu icon/startup correction1.0.1, iOS Apps recognition1.0.2, category tooltip removal1.0.3, optional Dock launcher and Prism icon1.1.0. The Dock design is approved and implemented; there is no pending design approval.

1.1.1: user-requested saved refresh-warning suppression delivered without changing scanning, validation or existing preferences.

1.2.0: responsive Dock grid delivered; explicitly authorized Developer ID signing verified for app and DMG.71 tests pass. Test relaunch workflow improved; historical file-not-found URL not identified and no recurrence in signed stable-path checks.

1.2.1: context-menu hiding/default uninstaller filtering complete,70 tests and signed package validation. Sharing indicator explained as OS presentation rather than app defect.

1.3.0 public milestone: detailed canonical user guide and Help wiring, MIT/repository support, signed distribution with install instructions, test-fixture and stale-artifact cleanup. GitHub release and owner tap publication follow verified source/artifact. Official Homebrew listing and notarization remain separate qualifications; notarization deferred by explicit owner choice.
