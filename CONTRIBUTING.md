# Contributing

Open an issue describing the problem or proposed improvement before a large change. For a small fix, a focused pull request with reproduction steps and relevant verification is welcome.

- Follow the repository's [AGENTS.md](AGENTS.md) contract and existing native SwiftUI/AppKit boundaries.
- Preserve app identities, visibility/category choices, backups and recovery. Never modify installed applications as part of discovery.
- Keep UI and persistence changes separate, with a clear compatibility story for saved catalogs.
- Update the canonical [Help.md](Help.md) when user behavior changes, and keep `project.yml` and the checked-in Xcode project synchronized.
- Run `./scripts/test.sh`, `swift test` for core changes, and strict governance verification as appropriate. Report anything you could not run; do not infer a pass.
- Do not commit generated apps, DMGs, catalogs, signing keys, API tokens, credentials or personal diagnostic data.

The macOS 27 SDK and runtime are required for native tests. The default GitHub workflow verifies governance; the native test workflow is manually dispatched on a compatible runner. Local release signing credentials are never provisioned through pull requests.

Changes are contributed under the project's [MIT License](LICENSE). Use [SECURITY.md](SECURITY.md) for sensitive reports.
