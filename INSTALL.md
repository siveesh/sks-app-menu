# Installation, updates and removal

## Requirements

- Apple silicon Mac, macOS 27.0 or later.
- No account, subscription or additional runtime package.
- Current releases are Developer ID-signed but not notarized. Gatekeeper may reject a downloaded copy. A normal public-download security qualification requires notarization; do not disable macOS security or remove quarantine attributes.

## Install from the disk image

1. Download the latest `SKsAppMenu-<version>-arm64.dmg` from [GitHub Releases](https://github.com/siveesh/sks-app-menu/releases).
2. Optionally compare its SHA-256 with the release's `SHA256SUMS.txt` using `shasum -a 256 /path/to/download.dmg`.
3. Open the DMG and drag **SK's App Menu.app** to its **Applications** shortcut.
4. Eject the image and launch the copy in Applications.
5. Click the grid icon in the macOS menu bar. No management window opens by default.
6. Enable **Show in Dock** for the grid, or choose **Open Launcher…** without adding a Dock icon.
7. Open **Help → SK's App Menu Help** for the full guide. `Help.md` is also included beside the app in the DMG.

Keep the original ApplicationMenu app separate. The new app does not overwrite it or import its configuration automatically. If Gatekeeper refuses the current unnotarized build, wait for a notarized release rather than bypassing the check.

## Install with Homebrew

```bash
brew tap siveesh/tap
brew trust --cask siveesh/tap/sks-app-menu
brew install --cask siveesh/tap/sks-app-menu
```

These commands target Homebrew 7. Review the source cask before trusting this specific definition; older versions may not have the trust command. Cask trust does not bypass Gatekeeper.

The owner tap is not an official Homebrew listing. Its pinned URL and checksum refer to the same release DMG, with the same notarization limitation. Homebrew does not launch the application automatically.

## Update

Quit the application before replacing its bundle. Replace only the earlier SK's App Menu.app. Preferences live separately in `~/Library/Application Support/com.siveesh.sksappmenu/` and are retained. For Homebrew, run `brew update` followed by `brew upgrade --cask siveesh/tap/sks-app-menu`.

## Remove

Quit the application and remove its app bundle, or run `brew uninstall --cask siveesh/tap/sks-app-menu`. This removes the launcher, not the applications it lists. Preferences are intentionally retained. Back up the settings folder before deleting it yourself if you want a complete reset.

## Support

See [Help.md](Help.md), [GitHub Issues](https://github.com/siveesh/sks-app-menu/issues), and the release notes. Include the app/build and macOS versions, but redact private paths and catalog contents. Never include credentials.
