# Open Issues

| ID | Issue | Impact / next step |
| --- | --- | --- |
| R1 | macOS 27.0 runtime not tested | Target is27.0; actual build/test host27.2.1. Qualify earliest supported OS before broad compatibility claim. |
| R2 | Notarization pending | 1.2.0 app and DMG use owner-authorized Developer ID signing. No notarization submitted or claimed; qualify public download distribution separately. |
| R3 | Manual accessibility/appearance qualification incomplete | Full VoiceOver, light-mode and repeated pointer/picker/Help/About QA remain. Native smoke+automated tests recorded separately. |
| R4 | Public repository licence not selected | No upstream code/assets imported. Owner's Relay identity images reused; select public licence before publishing. |
| E1 | Host tooling diagnostics | CoreSimulator mismatch, AppIntents extraction and autoShortcut logs; native macOS tests pass. hdiutil commands deprecated but successful. |

Resolved: design approvals; recursive discovery; persistent preferences and recovery; static-core test linkage; stale Add/Locate scans; ambiguous Locate; worker overlap; management layout; icon/width refinement (macOS27 explicit image visibility corrected in1.0.1). Broken Python shim worked around with /usr/bin/python3. Strict verifier excludes ignored generated artifacts.

D1 resolved in1.1.0: user explicitly approved the categorized Dock launcher; optional Dock presence, shared catalog and three saved densities implemented. Native runtime checks and59 automated tests pass.

Native compatibility follow-up: /System/Applications/Passwords.app is MacOSX with CFBundlePackageType XPC!, excluded by current APPL validation; it remains the single installed-scan warning. Confirmed iOS wrappers no longer warn.

T1: User reported a macOS file-not-found dialog during Codex test relaunches. Finder log correlates with native getApp attempt; exact missing URL not present. Catalog/scanner/resources check clean except known Passwords warning. Explicit app-targeted relaunch and signed stable-path QA launches show no recurrence. If it recurs, capture full dialog owner/missing URL before a source fix; do not suppress app diagnostics or treat signing as proof of the cause.

Window controls: resolved as OS behavior after user confirmed purple sharing icon. Native AX labels it Window sharing during visual capture. App retains standard native Window controls; no custom replacement or privacy suppression. Cmd-W/Cmd-M remain available. Source guidance in Help and Architecture.
