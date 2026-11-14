# Release and distribution workflow

## Current release decision

The owner authorized public GitHub source/DMG publication under MIT and an owner Homebrew tap. The owner explicitly deferred notarization while requesting [step-by-step setup guidance](Notarization.md). The current release is therefore **Developer ID-signed but unnotarized**, with that limitation stated in the guide, README, DMG and release notes. Do not describe it as Gatekeeper-approved or as an accepted official Homebrew cask.

## Prepare a release

1. Work from a clean branch. Update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`, then run `xcodegen generate`.
2. Update `Help.md`, `INSTALL.md`, `CHANGELOG.md`, support records and release notes. `Help.md` is the single app/DMG/GitHub guide; `docs/Help.md` only links to it.
3. Run the full tests and strict governance checks. Check resource inclusion, native Help menu/Contents behavior, catalog compatibility and actual launch.
4. Inspect the staged/public tree for credentials, user catalogs, generated products and stale links. Generated apps/DMGs stay out of Git; release assets belong on GitHub Releases.
5. Build and sign a fresh artifact. The script refuses to overwrite one with the same name.

```bash
SK_APP_MENU_SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)" \
  ./scripts/package.sh 1.3.0-arm64
```

The DMG contains the app, Applications shortcut, `Help.md`, `INSTALL.md`, `LICENSE` and a short Read Me. The script signs the app with Hardened Runtime/secure timestamp and signs the DMG. It does not notarize. Use the separate notarization workflow for a future fully qualified release, then calculate checksums after stapling.

## Verify and publish

1. Verify app and DMG signatures, authority/team and timestamps; verify the disk image checksum.
2. Mount read-only and copy/install from that exact image. Compare bundled Help to the canonical root file, launch the installed bundle and verify the version and preserved preferences.
3. Generate `SHA256SUMS.txt` from the final DMG. Use the exact published checksum and filename in `Casks/sks-app-menu.rb`.
4. Commit reviewed source/docs/cask, create an immutable version tag such as `v1.3.0`, and push to the owner repository's `main` branch.
5. Create the GitHub Release with the DMG, checksum file, guide and installation instructions. State the signing/notarization status and known limits prominently.
6. Download the public asset again, verify its checksum, and verify the release/tag links and GitHub workflow results.
7. Mirror the cask to `siveesh/homebrew-tap`; run syntax/style/download checks and report online/Gatekeeper audit limitations honestly. Do not submit to the official catalog while eligibility is unmet.

Do not overwrite an already published DMG or silently change its checksum. Use a new version for changed artifacts. Never upload signing credentials or user catalogs.

## Cleanup

Keep the current local testing app, current release DMG and diagnostic evidence required by the latest milestone. Remove superseded generated DMGs and obsolete QA/test bundles when the owner authorizes cleanup. Do not delete installed user applications, normal preference/backup files, source or unrelated archives. The persistent manual SK Launch Test bundle is not a release resource; integration tests create their own temporary controlled app and clean it up.

## Future automation

The governance workflow runs on pushes/PRs. A manual native-test workflow requires a compatible macOS 27 runner/SDK. There is no automatic credential provisioning, notarization, binary release upload or broad package publication on arbitrary pull requests. Refer to [Notarization.md](Notarization.md) before designing credential-backed release automation.
