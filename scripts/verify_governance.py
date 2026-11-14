#!/usr/bin/env python3
"""Verify the structural governance contract for an SK project repository."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


PHASES = ("kickoff", "architecture", "feasibility", "implementation", "qa", "documentation", "release")
BASELINE_FILES = (
    "AGENTS.md",
    "README.md",
    "CHANGELOG.md",
    ".gitignore",
    "docs/ProjectOverview.md",
    "docs/Architecture.md",
    "docs/Feasibility.md",
    "docs/ProjectSnapshot.md",
    "docs/OpenIssues.md",
    "docs/Roadmap.md",
    "docs/QA.md",
    "docs/Verification.md",
    "docs/ReleaseChecklist.md",
    "docs/SessionHandoff.md",
)
PHASE_REQUIREMENTS = {
    "kickoff": ("docs/ProjectOverview.md", "docs/ProjectSnapshot.md"),
    "architecture": ("docs/Architecture.md", "docs/Roadmap.md"),
    "feasibility": ("docs/Feasibility.md",),
    "implementation": ("docs/Architecture.md", "docs/Feasibility.md", "docs/Verification.md"),
    "qa": ("docs/QA.md", "docs/Verification.md"),
    "documentation": ("docs/SessionHandoff.md", "CHANGELOG.md", "docs/Verification.md"),
    "release": ("docs/ReleaseChecklist.md", "docs/Verification.md", "CHANGELOG.md"),
}


def read(root: Path, relative: str) -> str:
    return (root / relative).read_text(encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--phase", choices=PHASES, default="documentation")
    parser.add_argument("--strict", action="store_true", help="Fail on unresolved template markers and missing initialization state.")
    args = parser.parse_args()
    root = args.root.resolve()
    errors: list[str] = []
    warnings: list[str] = []

    for relative in BASELINE_FILES:
        path = root / relative
        if not path.is_file():
            errors.append(f"Missing required file: {relative}")
        elif not path.read_text(encoding="utf-8").strip():
            errors.append(f"Required file is empty: {relative}")
    if errors:
        return report(errors, warnings)

    agents = read(root, "AGENTS.md").lower()
    for required in ("sk-project-orchestrator", "macos-knowledge-base", "lessons-learned", "five required phases"):
        if required not in agents:
            errors.append(f"AGENTS.md is missing required governance reference: {required}")
    if (root / "AI_INSTRUCTIONS.md").exists():
        errors.append("AI_INSTRUCTIONS.md conflicts with this template's authoritative AGENTS.md contract.")

    for relative in PHASE_REQUIREMENTS[args.phase]:
        if not (root / relative).is_file():
            errors.append(f"Phase '{args.phase}' requires: {relative}")
    if args.phase in {"implementation", "qa", "release"}:
        if "status: approved" not in read(root, "docs/Architecture.md").lower():
            errors.append("Implementation-or-later work requires docs/Architecture.md to be marked Status: Approved.")
        if "status: approved" not in read(root, "docs/Feasibility.md").lower():
            errors.append("Implementation-or-later work requires docs/Feasibility.md to be marked Status: Approved.")
    if args.strict:
        for path in root.rglob("*"):
            if path.is_file() and path.suffix in {".md", ".yml", ".yaml", ".json"} and "__" in path.read_text(encoding="utf-8"):
                errors.append(f"Unresolved project marker: {path.relative_to(root)}")
        state_path = root / ".project-governance.json"
        if not state_path.is_file():
            errors.append("Missing .project-governance.json; run scripts/initialize_project.py in a copied template.")
        else:
            try:
                state = json.loads(state_path.read_text(encoding="utf-8"))
                if state.get("governance", {}).get("orchestrator") != "required":
                    errors.append(".project-governance.json does not require the orchestrator.")
            except json.JSONDecodeError:
                errors.append(".project-governance.json is not valid JSON.")
    if "DerivedData/" not in read(root, ".gitignore") or ".build/" not in read(root, ".gitignore"):
        warnings.append(".gitignore should cover DerivedData/ and .build/.")
    if not (root / ".github" / "workflows" / "governance.yml").is_file():
        warnings.append("No GitHub Actions governance workflow found.")
    return report(errors, warnings)


def report(errors: list[str], warnings: list[str]) -> int:
    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}")
    if errors:
        print(f"Governance verification failed: {len(errors)} error(s), {len(warnings)} warning(s).")
        return 1
    print(f"Governance verification passed: {len(warnings)} warning(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
