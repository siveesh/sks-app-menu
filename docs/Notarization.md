# Notarization: step-by-step setup and release guide

The owner explicitly deferred notarization for the current public release. The app and DMG are Developer ID-signed, but this guide is **not evidence of notarization**. These steps are for a future release and must be performed with the developer account locally. Never paste passwords or private keys into chat, Git, issues, or release notes.

## 1. Confirm the Apple developer account

1. Sign in at [Apple Developer Account](https://developer.apple.com/account/) using the Apple Account associated with the paid Developer Program membership.
2. Check Membership details. This project's installed Developer ID certificate belongs to **Siveesh Kodapully**, team **MURZTM33SD**. Confirm that this is the team you intend to use.
3. Resolve any account or agreement notices yourself in Apple's portal before using the notarization service. Do not share the account password.
4. Confirm two-factor authentication is enabled on the Apple Account.

You can inspect the installed signing identities without exporting a key:

```bash
security find-identity -v -p codesigning
```

Look for `Developer ID Application: Siveesh Kodapully (MURZTM33SD)`. An Apple Development or Apple Distribution certificate serves a different purpose. If the identity is missing, install the appropriate Developer ID certificate and its private key through your normal Apple/Xcode account workflow before proceeding.

## 2. Generate an app-specific password

1. Open [account.apple.com](https://account.apple.com/) and sign in yourself.
2. Open **Sign-In and Security → App-Specific Passwords**.
3. Choose **Generate an app-specific password** and give it a clear label such as `SK App Menu notarization`.
4. Keep the generated value private. You will enter it at a secure Terminal prompt in the next step; do not put it in a command-line argument or document.

Use an app-specific password, not the primary account password. Apple documents the prerequisites and revocation behavior in [Sign in to apps using app-specific passwords](https://support.apple.com/en-us/102654).

## 3. Save a local Keychain profile

Open Terminal. Replace only the email placeholder with the developer Apple Account email, then run:

```bash
xcrun notarytool store-credentials "sks-app-menu-notary" \
  --apple-id "YOUR_APPLE_ID_EMAIL" \
  --team-id MURZTM33SD
```

The omitted password option causes a secure password prompt. Enter the app-specific password there. Wait for successful validation and Keychain storage. The profile name `sks-app-menu-notary` is a reference to saved credentials, not a password.

If `xcrun` cannot find notarytool, install/select the intended Xcode toolchain first. For a credential error, confirm the account, team membership, app-specific password and account notices. Do not disable validation simply to make setup appear successful. Apple's [notarytool migration guide](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool) covers profile-based authentication.

## 4. Verify the profile without submitting a build

```bash
xcrun notarytool history --keychain-profile "sks-app-menu-notary"
```

An empty submission history is fine for a new team. Authentication errors are not. If you ask for help, share only the profile name and a redacted error message, never a password or key.

## 5. Prepare a new signed release

Work from a clean project checkout. Increment the app version/build in `project.yml`, regenerate the project with `xcodegen generate`, update Help/release notes as needed, and run the full tests. Use a new artifact version; never mutate a DMG already published on GitHub because that invalidates checksums and the Homebrew cask.

The existing `scripts/package.sh` signs and packages but **does not notarize**. For notarization, stage a fresh Release app before building the final DMG. The following example uses `1.3.1`; replace it consistently with the actual new release version. These are future workflow instructions, not commands run for the current release.

```bash
xcodebuild -project SKsAppMenu.xcodeproj -scheme SKsAppMenu \
  -configuration Release -derivedDataPath DerivedData build
mkdir -p Build/Distribution/1.3.1
ditto "DerivedData/Build/Products/Release/SK's App Menu.app" \
  "Build/Distribution/1.3.1/SK's App Menu.app"
codesign --force --sign "Developer ID Application: Siveesh Kodapully (MURZTM33SD)" \
  --options runtime --timestamp "Build/Distribution/1.3.1/SK's App Menu.app"
codesign --verify --deep --strict "Build/Distribution/1.3.1/SK's App Menu.app"
ditto -c -k --keepParent "Build/Distribution/1.3.1/SK's App Menu.app" \
  Build/Distribution/1.3.1/SKsAppMenu-1.3.1.zip
```

Use a fresh staging directory. Do not copy settings, test fixtures, signing material, or unrelated build products into the distribution.

## 6. Submit and staple the app

```bash
xcrun notarytool submit Build/Distribution/1.3.1/SKsAppMenu-1.3.1.zip \
  --keychain-profile "sks-app-menu-notary" --wait
```

Record the submission ID. Proceed only when the submission status is **Accepted**. Credential validation and upload completion alone do not mean acceptance. If the status is Invalid, fetch its log using `xcrun notarytool log SUBMISSION_ID --keychain-profile "sks-app-menu-notary" notary-log.json`, diagnose the reported signing/runtime issue, and submit a corrected new candidate. Do not publish it as notarized.

After acceptance:

```bash
xcrun stapler staple "Build/Distribution/1.3.1/SK's App Menu.app"
xcrun stapler validate "Build/Distribution/1.3.1/SK's App Menu.app"
spctl --assess --type execute --verbose=2 "Build/Distribution/1.3.1/SK's App Menu.app"
```

Require successful stapler validation and Gatekeeper assessment. Read the full assessment output: an acceptance caused by a local policy override does not qualify a public download. Verify on a clean Mac using default security settings. The staged app now contains its ticket; do not re-sign or alter it afterward.

## 7. Package, sign and notarize the final DMG

Copy the stapled app into a fresh DMG staging folder with `Help.md`, `INSTALL.md`, `LICENSE`, a short Read Me and an Applications link. Update the release documentation to reflect the **actual** notarization result. Do not edit files inside the signed app bundle.

```bash
mkdir -p Build/Distribution/1.3.1/DMG
ditto "Build/Distribution/1.3.1/SK's App Menu.app" \
  "Build/Distribution/1.3.1/DMG/SK's App Menu.app"
cp Help.md INSTALL.md LICENSE Build/Distribution/1.3.1/DMG/
ln -s /Applications Build/Distribution/1.3.1/DMG/Applications
hdiutil create -volname "SK's App Menu" -srcfolder Build/Distribution/1.3.1/DMG \
  -format UDZO Release/SKsAppMenu-1.3.1-arm64.dmg
codesign --sign "Developer ID Application: Siveesh Kodapully (MURZTM33SD)" \
  --timestamp Release/SKsAppMenu-1.3.1-arm64.dmg
xcrun notarytool submit Release/SKsAppMenu-1.3.1-arm64.dmg \
  --keychain-profile "sks-app-menu-notary" --wait
```

After this submission is Accepted, staple and validate the DMG:

```bash
xcrun stapler staple Release/SKsAppMenu-1.3.1-arm64.dmg
xcrun stapler validate Release/SKsAppMenu-1.3.1-arm64.dmg
codesign --verify --strict Release/SKsAppMenu-1.3.1-arm64.dmg
hdiutil verify Release/SKsAppMenu-1.3.1-arm64.dmg
shasum -a 256 Release/SKsAppMenu-1.3.1-arm64.dmg
```

Calculate the published checksum **after** stapling. Copy/install from the final image and test the app before release. Keep the submission IDs, acceptance results, signature and Gatekeeper evidence with the release records. Apple's [custom notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow) explains submission and stapling.

## 8. Publish the new version and update the cask

Publish a new immutable tag/release and the final DMG with its SHA-256. Update the cask version, URL and checksum in this repository and `siveesh/homebrew-tap`, then rerun style, download and online/Gatekeeper checks. Remove the unnotarized caveat only after the published artifact passes the checks. A notarized release still must meet Homebrew's other acceptance criteria before an official listing.

## Credential maintenance

Do not place the profile's credentials in GitHub Actions unless you deliberately configure a secure release automation workflow later. No such credentials are provisioned by this project. If an app-specific password is revoked or the Apple Account password changes, repeat local profile setup with a valid replacement. Keep passwords out of shell history, logs, chat and Git.
