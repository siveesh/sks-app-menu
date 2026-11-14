# QA and Performance

Status: Automated QA passed; native smoke assessment complete with documented manual follow-ups.
Reviewed: 2026-11-14. See Verification.md for commands, actual results and artifact paths.

## Findings and resolutions

| Finding | Resolution | Evidence |
| --- | --- | --- |
| External catalog corruption left model editable with inaccessible recovery | Enter read-only recovery mode for validation/decoding failures; transient I/O remains retryable | Model recovery regression passed |
| Stale scan marked a newly manually added app missing | Cancel/invalidate old snapshot; queue one fresh scan after worker exits | Gated regression RED then GREEN |
| Locate into rediscovered ambiguous copy stranded preferences | Rebind chosen missing UUID and preferences; remove physical duplicate; confirm target preference conflicts | Regression RED then GREEN |
| Stop/restart could overlap scan workers | Retain worker until completion and coalesce rescan | Gated regression RED then GREEN |
| Management list compressed into bottom strip | Explicit vertical filling/top alignment | Rebuilt and visually inspected |
| App icons not guaranteed before submenu layout; labels made menu wide | Native cached icons attached before layout, shortened status/action labels, 240-point text budget and full tooltips | User-requested refinement built; final suite GREEN |
| Hosted tests duplicated static core runtime types | Host-only linkage via link:false test dependency | Cast regression passed; duplicate class diagnostic gone |

## Acceptance evidence

31 Xcode tests pass, including 22 core, eight model, and a controlled actual exact-URL launch. Real recursive discovery finds Photoshop and Resolve vendor installations. Persistence, invalid-file protection, recovery, category deletion fallback, duplicate identity and scan races covered. Native keyboard selection observed; picker opens; menu app runs from designated testing folder.

1,000-fixture scan 0.339s and warm merge 0.032s. Installed scan .168s for144 apps. No continuous scan timer. Menu opening latency and idle allocation/cpu sampling are not fully profiled.

## Remaining manual qualification

Full VoiceOver, light appearance, repeated pointer-based picker/cancel, Help/About visual pass, and macOS27.0 runtime. Native control session was intermittently invalidated by external state; do not treat that as product failure or complete manual acceptance. Public distribution remains pending Developer ID signing/notarization and owner licence decision.
