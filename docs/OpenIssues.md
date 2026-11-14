# Open Issues

| ID | Issue | Impact / next step |
| --- | --- | --- |
| R1 | macOS 27.0 runtime not tested | Target is27.0; actual build/test host27.2.1. Qualify earliest supported OS before broad compatibility claim. |
| R2 | Local ad-hoc package only | Developer ID identity/notarization access not established; do not publish as a notarized public release. |
| R3 | Manual accessibility/appearance qualification incomplete | Full VoiceOver, light-mode and repeated pointer/picker/Help/About QA remain. Native smoke+automated tests recorded separately. |
| R4 | Public repository licence not selected | No upstream code/assets imported. Owner's Relay identity images reused; select public licence before publishing. |
| E1 | Host tooling diagnostics | CoreSimulator mismatch, AppIntents extraction and autoShortcut logs; native macOS tests pass. hdiutil commands deprecated but successful. |

Resolved: design approvals; recursive discovery; persistent preferences and recovery; static-core test linkage; stale Add/Locate scans; ambiguous Locate; worker overlap; management layout; icon/width refinement (macOS27 explicit image visibility corrected in1.0.1). Broken Python shim worked around with /usr/bin/python3. Strict verifier excludes ignored generated artifacts.
