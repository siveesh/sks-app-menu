#!/usr/bin/env python3
"""Initialize a copied SK Project Template without touching the template itself."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path


MARKERS = {
    "__PROJECT_NAME__",
    "__BUNDLE_IDENTIFIER__",
    "__PROJECT_SLUG__",
    "__TARGET_PLATFORM__",
    "__INITIALIZATION_DATE__",
    "__TEMPLATE_STATE__",
}


def slugify(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    if not slug:
        raise ValueError("Project name must contain letters or numbers.")
    return slug


def replace_markers(root: Path, values: dict[str, str]) -> int:
    changed = 0
    for path in root.rglob("*"):
        if not path.is_file() or ".git" in path.parts or path.suffix not in {".md", ".yml", ".yaml", ".json"}:
            continue
        text = path.read_text(encoding="utf-8")
        updated = text
        for marker, value in values.items():
            updated = updated.replace(marker, value)
        if updated != text:
            path.write_text(updated, encoding="utf-8")
            changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--name", required=True)
    parser.add_argument("--bundle-id", required=True)
    parser.add_argument("--platform", default="macOS")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--no-git", action="store_true", help="Do not initialize a Git repository.")
    args = parser.parse_args()

    root = args.root.resolve()
    overview = root / "docs" / "ProjectOverview.md"
    if not (root / "AGENTS.md").is_file() or not overview.is_file():
        parser.error(f"{root} does not look like an SK Project Template copy.")
    overview_text = overview.read_text(encoding="utf-8")
    if "__PROJECT_NAME__" not in overview_text:
        parser.error("This project is already initialized; refuse to overwrite its identity.")
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9.-]+", args.bundle_id):
        parser.error("--bundle-id must be a reverse-DNS-style identifier using letters, digits, dots, or hyphens.")

    initialized = dt.date.today().isoformat()
    values = {
        "__PROJECT_NAME__": args.name,
        "__BUNDLE_IDENTIFIER__": args.bundle_id,
        "__PROJECT_SLUG__": slugify(args.name),
        "__TARGET_PLATFORM__": args.platform,
        "__INITIALIZATION_DATE__": initialized,
        "__TEMPLATE_STATE__": "yes",
    }
    changed = replace_markers(root, values)
    remaining = []
    for path in root.rglob("*"):
        if path.is_file() and path.suffix in {".md", ".yml", ".yaml", ".json"}:
            text = path.read_text(encoding="utf-8")
            remaining.extend(marker for marker in MARKERS if marker in text)
    if remaining:
        print(f"Initialization stopped: unresolved template markers: {sorted(set(remaining))}", file=sys.stderr)
        return 1

    state = {
        "schema_version": 1,
        "project_name": args.name,
        "bundle_identifier": args.bundle_id,
        "platform": args.platform,
        "initialized": initialized,
        "governance": {"orchestrator": "required", "phase": "kickoff"},
    }
    (root / ".project-governance.json").write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    if not args.no_git and not (root / ".git").exists():
        git = shutil.which("git")
        if git:
            subprocess.run([git, "init"], cwd=root, check=True)
        else:
            print("Warning: Git is unavailable; initialize the repository manually.", file=sys.stderr)
    print(f"Initialized {args.name} ({changed} files updated) at {root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

