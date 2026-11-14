# Project Governance Contract

This file is the authoritative instruction layer for this repository. Do not create a competing `AI_INSTRUCTIONS.md`.

## Required orchestration

- Use `sk-project-orchestrator` for a new project, new feature, major refactor, release, or recovery from an incomplete session.
- Retrieve governance guidance before each phase. Use `macos-knowledge-base` (or the orchestrator's bundled fallback) before selecting Apple APIs, frameworks, entitlements, accessibility behavior, performance work, packaging, or distribution behavior.
- Use `lessons-learned` after each completed phase and after a genuine mistake or correction. Record real observations only; never invent lessons.
- Keep project-specific decisions in this repository's `docs/` files. The repository is the source of truth, not chat history.

## Five required phases

1. Project Architect: scope, MVP, modules, risks, milestones, and architecture. No production code.
2. Research & Feasibility: compare options, platform constraints, licences, dependencies, and make a recommendation.
3. Implementation: make small changes that follow the approved architecture.
4. QA & Performance: inspect bugs, safety, security, memory, performance, error handling, and compatibility before changing anything.
5. Documentation: update the documentation, verification evidence, changelog, and next-session handoff.

Do not start phase 3 until phases 1 and 2 are documented and either approved or proceeding under explicitly recorded assumptions.

## Non-negotiable safeguards

- Protect user data, databases, original media, archives, storage locations, credentials, and recoverability.
- Do not perform destructive actions or overwrite an existing app/data store without explicit confirmation.
- Prefer native Apple frameworks and local/on-device processing for Apple-platform projects unless a documented decision says otherwise.
- Do not claim a build, test, launch, install, cleanup, or release succeeded without recorded evidence.
- Keep dependencies justified, repositories clean, and generated artifacts out of version control unless explicitly required.

## Required project records

Read these before changing code when present, and update the relevant record before ending a phase:

1. `docs/ProjectOverview.md`
2. `docs/Architecture.md`
3. `docs/ProjectSnapshot.md`
4. `docs/OpenIssues.md`
5. `docs/Roadmap.md`
6. `docs/Feasibility.md`
7. `docs/QA.md`
8. `docs/Verification.md`
9. `docs/SessionHandoff.md`

Run `python3 scripts/verify_governance.py --strict --phase documentation` before committing a completed milestone. The verifier enforces structure and evidence fields; it does not replace engineering judgment, review, or tests.

