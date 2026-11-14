#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
hook="$root/.git/hooks/pre-commit"

if [[ ! -d "$root/.git" ]]; then
  echo "Git is not initialized. Run scripts/initialize_project.py first." >&2
  exit 1
fi
if [[ -e "$hook" ]]; then
  echo "Refusing to overwrite existing hook: $hook" >&2
  exit 1
fi

install -m 755 "$root/scripts/pre-commit-governance" "$hook"
echo "Installed governance pre-commit hook at $hook"

