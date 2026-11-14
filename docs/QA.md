# QA and Performance

Status: Planned; no app exists yet
Last reviewed: 2026-11-14

## Acceptance matrix

| Requirement | Planned evidence |
| --- | --- |
| Nested vendor discovery | Photoshop-style and Resolve-style bundle fixtures at multiple depths; real installed paths if available |
| Package boundaries | Embedded helper fixture excluded; ordinary Utilities/vendor folders included |
| Browse/Add | Valid app accepted; invalid selection rejected; cancellation unchanged; repeated add deduplicated |
| Hide/restore | Removed from menu, present in Hidden filter; survives refresh and restart |
| Categories | Metadata fallback, override precedence, custom rename/delete, Automatic reset, persistence |
| Identity | Copies sharing identifier remain distinct; move recovery; ambiguous match requires Locate |
| Failures | Partial roots retain unverified records; corrupt/newer store read-only; save failure remains unsaved |
| Concurrency | Refresh coalesces/cancels; stale result cannot overwrite edit; menu tracking defers rebuild |
| Usability | Empty catalog, all hidden, keyboard, VoiceOver, dark/light, window close and quit |
| Launch | Exact URL, missing/denied app error; no security bypass |
| Performance | 1,000 fixture bundles, measured scan/menu latency, idle CPU and memory |
| Release | Help/About, icon, built app version/name, signing/notarization and OS evidence |

## Design review

Independent builder review requested before handing the documents to the user. Findings and resolutions will be recorded in Verification.md. No functional tests, runtime QA, performance profiling, or compatibility certification has occurred.
