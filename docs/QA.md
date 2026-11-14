# QA and Performance

Current baseline:1.1.0,59 automated tests pass.

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

## 1.0.1 startup and icon correction — 2026-11-14

User reported default management-window opening and absent app icons despite assigned images. SDK NSMenuItem.h and Apple's preferredImageVisibility reference confirm macOS27 defaults image visibility to Automatic and typically hides images. Set each application row to .visible explicitly; do not change global macOS preferences. The new real-menu regression failed with Automatic(rawValue0) versus Visible(rawValue1), then passed. All32 Xcode tests pass; result bundle Test-SKsAppMenu-2026.11.14_11-53-30-+0300.xcresult. Prior final handoff was launched with --manage; normal launch now omits that flag and every utility scene disables restoration as well as suppressing default launch. Explicit management access remains in the menu.

Sources: https://developer.apple.com/documentation/appkit/nsmenuitem/preferredimagevisibility and https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:). No new framework, entitlement or storage change. Release version1.0.1, build2. Logs retained in Build/Evidence. Native startup verification and package results are appended after observation.

Final1.0.1 outcome: Release build succeeded; Release/SKsAppMenu-1.0.1-local.dmg created/checksum verified, mounted read-only and detached. Packaged app strict signature passed; previous local test app archived to Build/Previous-1.0.0 and new app placed at Build/Testing. Process9097 observed with no launch arguments; bundle version1.0.1. Normal Application Support catalog was not modified by deployment. CUA could not bind a window surface to the menu-only app (timeout); functional image-policy verification is the actual NSMenu regression, not an unobserved screenshot. Logs copied to Build/Evidence/sks-101-*.log.

## iOS-on-Mac discovery —1.0.2(4),2026-11-14

Direct user request implemented as scanner compatibility correction while Dock design remains pending approval. Five installed apps use outer .app/Wrapper/<payload>.app/Info.plist plus WrappedBundle link; native Contents/Info.plist assumption produced false warnings. Scanner now supports canonical contained wrapped/flat iOS layouts, requires positive iPhoneOS/LSRequiresIPhoneOS metadata and APPL/executable validation, keeps outer app URLs for launch/icons/identity, and defaults them to iOS Apps. Invalid, unreadable, external-link and ambiguous payloads continue to warn; user category overrides win.

Regression evidence: original iOS fixtures ran RED with five failing assertions, then passed. Permission fixture correctly adds both per-app and partial-root warnings; assertion refined to verify both rather than assume one warning per error. Legacy custom iOS Apps category fixture failed the new built-in name validation; compatibility exception preserves loaded categories/assignments without weakening UI duplicate-name creation rules. Independent read-only reviews found no Important/Critical issues.

Full Xcode suite:37 tests, zero failures (27 core/store and10 app), TEST SUCCEEDED. Result: DerivedData/Logs/Test/Test-SKsAppMenu-2026.11.14_12-10-19-+0300.xcresult. Installed production scan:149 apps, one native-bundle warning, zero failed roots; eGlu, Hik-Connect, Krzene, Nuvio and STARZPLAY in iOS Apps. Passwords.app declares native MacOSX/XPC! and is not mislabeled iOS; supporting native XPC app packaging is a separate compatibility item. No iOS application was launched during this metadata check.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

##1.1.0 Dock and icon qualification

Approved design implemented. Independent review found minimized-launcher error routing skipped restoration; corrected with a failing then passing regression. Native QA found a nil-tag All Applications row could not be selected after a category; replaced it with an explicit selection case and verified category→All restores149 visible entries.

Native isolated runtime verified saved Dock-on startup opens launcher without management, all three densities, five iOS Apps with icons, search yielding the single controlled fixture, Down/Return exact-URL launch, minimized restore via standard application reopen, Dock disable control and explicit launcher access with Dock off. No real installed app was launched by these checks. Exact Dock mouse click is not separately claimed; production reopen handler and standard reopen path were exercised. Full VoiceOver/light appearance remain open.

Prism icon compiled with native actool; Default, Dark and Mono were visually inspected in Icon Composer. Native1024px export retained. No runtime bundle mutation or permission/entitlement expansion. No new performance benchmark claim; density/search inspect149 visible records from isolated store. Some CUA operations were invalidated by external state; repeated fresh observations resolved these without changing privacy settings.

Final full Xcode suite59/59 passes; source/resource integration built on macOS27.2.1 with Xcode27.2/Swift6.4.2. See Verification.md for exact logs/result bundle and final package deployment.
