# SK's App Menu — Feasibility Recommendation

Status: Approved
Decision owner: Siveesh
Last reviewed: 2026-11-14

## Recommendation

Proceed with a native Swift rebuild: SwiftUI management windows, an isolated AppKit NSStatusItem/NSMenu adapter, Foundation directory enumeration and Codable persistence, and NSWorkspace launches. No external packages or services are needed for the requested MVP. Use Xcode 27.2 and the installed Apple Swift 6.4.2 compiler in Swift 6 language mode. Recommend macOS 27.0+ and Apple silicon for the first release. This is a documented feasibility assessment, not evidence of a tested app. Implementation approved by Siveesh on 2026-11-14.

## Evidence and current platform

Local inspection during kickoff returned Xcode 27.2, build 27B52; Apple Swift 6.4.2, target arm64-apple-macosx27.2.0. Apple's current Xcode matrix lists the Xcode 27.2 SDK and Swift 6.4 compiler family. It also lists a newer beta Xcode; choose the stable installed toolchain rather than introduce a beta solely for this utility. Toolchain installation does not establish product compatibility. Initial runtime evidence will be on the development Mac; macOS 27.0 needs separate testing before advertising the full 27.x range as verified.

## Options and trade-offs

| Concern | Recommendation | Alternatives and consequences |
| --- | --- | --- |
| Product base | Independent native rebuild; selected by user | Extending MIT upstream may save work but requires deeper source review; no copied implementation yet |
| Menu | NSStatusItem + NSMenu, isolated adapter | SwiftUI MenuBarExtra is viable and simpler but offers less explicit menu-tracking control |
| Management | SwiftUI with native app picker | Full AppKit adds UI boilerplate; web UI adds an unnecessary runtime |
| Discovery | Recursive FileManager enumeration with package boundaries | Spotlight may be stale, disabled, or incomplete; bundle-identifier lookup does not enumerate all installed copies |
| Persistence | Versioned atomic JSON plus backup, serial actor | UserDefaults suits tiny flags but not this identity/recovery store; SwiftData adds migration/framework complexity without a query need |
| Distribution | Unsandboxed direct distribution with Hardened Runtime | App Store requires App Sandbox and a scoped-access feasibility revisit; sandboxed direct distribution is possible but adds permission/bookmark handling |
| Project tooling | Xcode app and test targets, standard Apple tooling | A generated project or SwiftPM app packaging would add tooling without a demonstrated need |

## Platform API support

- NSStatusItem exposes a native menu-bar button and attached NSMenu. Keep menu work on MainActor.
- FileManager deep enumeration supports recursive directories and an error handler. It does not follow encountered directory symlinks, so vendor directories work without recursively following links. Skip package descendants and hidden files. Root URLs must be resolved if symlinks.
- NSOpenPanel supports explicit app selection; configure package selection and application content types and validate the resulting target. A picker grant is not a promise of permanent filesystem access. Use ordinary persistent bookmarks for relocation in the recommended unsandboxed build; do not request security-scope entitlements unless sandboxing is selected later.
- NSWorkspace opens a particular application URL asynchronously and returns success/error. This preserves copy/version choice and normal OS security checks.
- LSApplicationCategoryType provides app category metadata but describes an App Store category and may be absent in directly distributed apps. Other plus manual override is essential; an exhaustive correct automatic category cannot be promised.

## Permissions and release constraints

The proposed utility needs no daemon, privileged helper, Full Disk Access, Apple Events, or Accessibility automation permission. Reading bundle metadata can still fail because of ordinary filesystem restrictions or privacy controls. Errors must remain visible, with manual selection as a recovery path. Never recommend elevated access as the default fix.

The absence of App Sandbox is an intentional trade-off for a small local launcher; Hardened Runtime does not replace sandboxing. Restrict operations in application logic to app metadata, launches, and the app's own store. Enable Hardened Runtime without exception entitlements. Developer ID signing and notarization require an available developer identity and credentials; neither has been inspected or provisioned. A local development build and a distributable signed/notarized build are separate milestones. Do not install over the user's existing launcher.

## Licence and branding

Upstream GitHub lists MIT. No upstream code or assets have been imported, and this design does not assume its internal algorithm. If anything is reused, inspect its actual licence and preserve the required attribution/notice before shipping. Prefer original icon/branding for SK's App Menu. Repository licensing remains the owner's decision before public distribution. Consult the existing Relay About reference and confirm reusable assets during implementation; missing reference assets must be reported rather than fabricated.

## Validation still required

1. Build the actual targets with Swift 6 concurrency checking; fix isolation rather than suppressing warnings broadly.
2. Fixture tests for nested vendor apps, helpers inside bundles, malformed apps, symlink/alias handling, duplicate names and identifiers, missing roots, denied roots, moved apps, and partial scans.
3. Persistence tests for hide/category edits across restart, interrupted/failed saves, corrupt store and backup, newer schema, rapid edits, and refresh/edit races.
4. Runtime launch of a controlled app by exact URL; cancellation/quit; menu tracking; management window activation; native picker behavior; VoiceOver and keyboard access.
5. Measured catalog/menu latency and idle CPU; no benchmarks have been run. Test real Adobe/Resolve installation paths only when available and without launching them automatically.
6. Verify icon compilation, Help/About, packaging, signing/notarization, and any supported OS claims before release.

## Revisit triggers and unresolved limits

Revisit for Mac App Store distribution, pre-27 systems or Intel support, global hotkeys, login launch, auto-updates, cloud sync, executable-less application wrappers, or a demonstrated need to discover apps through linked directories. The proposed first milestone excludes these. No core SDK blocker is identified from documentation; permissions, identity matching, and persistence recovery are the main implementation risks.

## Sources consulted on 2026-11-14

- [Apple Xcode support matrix](https://developer.apple.com/xcode/system-requirements/)
- [NSStatusItem](https://developer.apple.com/documentation/appkit/nsstatusitem)
- [FileManager recursive enumeration](https://developer.apple.com/documentation/foundation/filemanager/enumerator(at:includingpropertiesforkeys:options:errorhandler:))
- [NSOpenPanel](https://developer.apple.com/documentation/appkit/nsopenpanel)
- [NSWorkspace application launch](https://developer.apple.com/documentation/appkit/nsworkspace/openapplication(at:configuration:completionhandler:))
- [LSApplicationCategoryType](https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype)
- [App Sandbox](https://developer.apple.com/documentation/security/app-sandbox)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime)
- [Upstream reference](https://github.com/barseghyanartur/app-menu/)
- Local orchestrator retrieval: AppKit delegate bridge, advanced development workflow, sandbox filesystem access, Hardened Runtime requirements. Retrieved unrelated extension/RAG/AVFoundation chunks were not used to select APIs. Unverified/speculative corpus statements were not adopted.

## 1.0.1 startup and icon correction — 2026-11-14

User reported default management-window opening and absent app icons despite assigned images. SDK NSMenuItem.h and Apple's preferredImageVisibility reference confirm macOS27 defaults image visibility to Automatic and typically hides images. Set each application row to .visible explicitly; do not change global macOS preferences. The new real-menu regression failed with Automatic(rawValue0) versus Visible(rawValue1), then passed. All32 Xcode tests pass; result bundle Test-SKsAppMenu-2026.11.14_11-53-30-+0300.xcresult. Prior final handoff was launched with --manage; normal launch now omits that flag and every utility scene disables restoration as well as suppressing default launch. Explicit management access remains in the menu.

Sources: https://developer.apple.com/documentation/appkit/nsmenuitem/preferredimagevisibility and https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:). No new framework, entitlement or storage change. Release version1.0.1, build2. Logs retained in Build/Evidence. Native startup verification and package results are appended after observation.

## Dock launcher feasibility addendum — Proposed, approval pending

Recommend the same app/process with native SwiftUI launcher and AppKit dynamic activation policy/reopen adapter, rather than a second binary. Official Apple sources, constraints, persistence compatibility and runtime acceptance checks are in [Dock launcher design](superpowers/specs/2026-11-14-dock-launcher-design.md). No additional entitlements or packages are proposed. Reopen/minimization and Dock transitions still require runtime proof. Existing1.0.1 feasibility approval does not represent approval of this new addendum.

## iOS-on-Mac layout correction —2026-11-14

Read-only installed inspection confirms five real iOS wrappers with root-level payload Info.plist and executable. Native Foundation can read those files; missing macOS Contents/Info.plist is not proof of inaccessible data. Use LSRequiresIPhoneOS/CFBundleSupportedPlatforms iPhoneOS markers, canonical containment and the outer app URL. No new dependency/permissions. Apple Info.plist and bundle-structure references: https://developer.apple.com/documentation/bundleresources/information-property-list and https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html. Direct user-approved compatibility fix, independent of pending Dock addition.
