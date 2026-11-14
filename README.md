# SK's App Menu

`SK_PROJECT_TEMPLATE_READY: yes`

A proposed native macOS menu-bar launcher with recursive application discovery, manual app selection, reversible hiding, and persistent category overrides.

## Current status

Design and feasibility prepared for review. No application code, executable, build, or runtime test yet. Native rebuild approach and product name selected by Siveesh on 2026-11-14; the detailed design still requires approval before implementation.

- [Architecture](docs/Architecture.md)
- [Feasibility and sources](docs/Feasibility.md)
- [Verification evidence](docs/Verification.md)
- [Session handoff](docs/SessionHandoff.md)

## Proposed platform and identity

- Display name: SK's App Menu
- Internal target: SKsAppMenu
- Bundle identifier: com.siveesh.sksappmenu (provisional)
- Repository slug: sks-app-menu
- Proposed deployment: macOS 27.0+, Apple silicon
- Inspected toolchain: Xcode 27.2, Apple Swift 6.4.2
- Working folder remains Application Menu

## Repository

AGENTS.md is the authoritative contract. docs/ contains phase records; scripts/ contains template initialization, governance verification, and hook installation; .github/workflows/ contains governance CI. Add app/test targets only after approval.

## Governance verification

Use the working system interpreter on this Mac (the default pyenv shim is broken):

```bash
/usr/bin/python3 scripts/verify_governance.py --strict --phase documentation
```

The governance pre-commit hook is installed. Its checks verify document structure; they do not establish app correctness. Build/run instructions will be added with the implementation rather than inventing commands for targets that do not yet exist.

## Distribution and licence

Proposed direct distribution, local storage, no online services or third-party packages. No upstream code/assets imported. Signing, notarization, project licensing, and distribution readiness remain unverified. Reference: https://github.com/barseghyanartur/app-menu/.
