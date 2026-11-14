# Session Handoff

- **Updated:** 2026-11-14
- **Product:** SK's App Menu
- **Current phase:** Architecture and feasibility drafted/reviewed; user approval pending

## Confirmed decisions

User selected native rebuild and the name SK's App Menu. Metadata uses provisional com.siveesh.sksappmenu; internal target SKsAppMenu. Existing Application Menu workspace folder retained.

## Reviewable deliverables

Architecture.md contains behavior, modules, discovery boundaries, app identity, persistent overrides, recovery, concurrency, and acceptance criteria. Feasibility.md compares frameworks, storage, discovery and distribution with official Apple sources. Independent builder review reported “nothing important left.” No product implementation exists.

## Proposed defaults requiring design approval

macOS 27.0+, Apple silicon; installed stable Xcode 27.2/Swift 6.4.2, Swift 6 mode; AppKit native menu plus SwiftUI management; local JSON storage; direct unsandboxed distribution with Hardened Runtime; no online dependencies. Runtime compatibility and signing remain untested.

## Verification and lessons

Strict kickoff, architecture and feasibility checks returned exit 0, zero warnings. Final documentation verification is recorded in Verification.md. Default python3 is a broken pyenv shim; use /usr/bin/python3. The project pre-commit script and installed hook now explicitly invoke the system interpreter. Genuine interpreter lesson appended through the orchestrator lessons-learned bridge; no invented product lessons.

## Next actions

1. Obtain explicit approval of Architecture.md and Feasibility.md, or revise requested details.
2. Invoke writing-plans after approval; retrieve implementation-specific macOS knowledge before Apple API implementation.
3. Implement approved core, then menu and management, then Help/About/branding in focused increments.
4. Execute QA and performance phase, then final documentation phase. Never infer app build/install/release evidence from governance checks.

## Retention

No app installed, original app-menu untouched, no temporary build artifacts generated. Keep documentation and template tooling under version control. Upstream source algorithm and reusable About assets still need inspection before any reuse.
