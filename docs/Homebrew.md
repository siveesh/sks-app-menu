# Homebrew distribution

## Owner tap

The app's cask is maintained in this repository at `Casks/sks-app-menu.rb` and mirrored to [siveesh/homebrew-tap](https://github.com/siveesh/homebrew-tap). It uses the versioned GitHub release DMG, its exact SHA-256, an Apple silicon requirement, and a macOS 27 minimum. It installs only SK's App Menu.app. There is no `zap` stanza; launcher preferences are retained on uninstall.

```bash
brew tap siveesh/tap
brew trust --cask siveesh/tap/sks-app-menu
brew install --cask siveesh/tap/sks-app-menu
```

This custom tap is not an official Homebrew listing or endorsement. The current DMG is Developer ID-signed **but unnotarized**. A checksum verifies artifact identity, not Gatekeeper acceptance. A clean default-security download/launch qualification is not established for this release; never use quarantine removal or security-disabling workarounds in this cask.

## Validation and maintenance

Homebrew 7 refuses to load third-party casks until trusted. Review and trust only this cask, rather than granting broad tap trust.

For each new release:

1. Publish the final versioned DMG and checksum without overwriting older release assets.
2. Update version, URL and SHA-256 in the source cask and owner tap.
3. Run `brew style --cask` for the tap cask, `brew info --cask`, `brew fetch --cask`, and an online audit on a compatible host.
4. Record what passed and what did not. Style/parse/fetch success does not mean the app passed notarization, Gatekeeper or upstream acceptance.
5. Verify `livecheck` against published GitHub Releases. Do not mark a cask `auto_updates` because this app has no updater.

Latest concrete results are recorded in [Verification.md](Verification.md); do not infer an installation/launch pass from this workflow description.

## Official Homebrew listing

Checked against Homebrew's policy on 2026-11-14. The shared [Package Acceptance Policy](https://docs.brew.sh/Package-Acceptance-Policy) normally excludes code repositories less than 30 days old and requires demonstrated public interest. Its current GitHub thresholds are at least 30 forks, 30 watchers or 75 stars, with higher thresholds for self-submissions. The new repository has not established that eligibility.

[Acceptable Casks](https://docs.brew.sh/Acceptable-Casks) additionally requires declared platform compatibility, verifiable upstream distribution and passing Gatekeeper checks. Notarization is explicitly deferred by the owner for this release, so the security qualification is not met either. No upstream pull request is submitted merely to create a predictable rejection.

When a notarized release passes checks and the project meets current notability/age requirements, reassess the then-current policies and prepare a focused `Homebrew/homebrew-cask` submission. Acceptance is the maintainers' decision. In the meantime, a [third-party tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap) is Homebrew's supported route for software outside the official criteria.
