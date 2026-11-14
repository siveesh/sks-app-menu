# Open Issues

| ID | Issue | Impact / proposed resolution | Decision needed by |
| --- | --- | --- | --- |
| D1 | Detailed design approval pending | User review of Architecture.md and Feasibility.md, including proposed macOS 27+ / Apple silicon / direct distribution defaults | Implementation |
| R1 | macOS 27.0 runtime not tested | Development host/toolchain inspection is not 27.0 compatibility evidence | Compatibility claim |
| R2 | Signing identity and notarization access unverified | Local build can precede credentials; distributable release cannot claim signed/notarized without evidence | Release |
| R3 | Upstream source algorithm not inspected | Do not assert its root cause; no code imported | Any upstream reuse |
| R4 | Repository licence and About asset rights | Owner selects public licence; inspect Relay references and any reused assets | Public release |
| E1 | Default Python shim broken | Use /usr/bin/python3; project hook adapted to invoke system interpreter | Resolved workaround |
