# SK's App Menu — Architecture

Status: Approved
Last reviewed: 2026-11-14

## Intent and decisions

Replace the categorized menu-bar launcher with a native Swift app that discovers apps inside vendor folders and gives the owner lasting control over visibility and categories. User selected the native rebuild approach on 2026-11-14 and named the product SK's App Menu. This selects the approach; both documents were approved by Siveesh on 2026-11-14.

Identity: display name `SK's App Menu`; provisional bundle identifier `com.siveesh.sksappmenu`; internal target `SKsAppMenu`; repository slug `sks-app-menu`. Keep the existing workspace folder to avoid disrupting the open workspace.

## Scope and non-goals

MVP: categorized launching with names and icons; recursive discovery; explicit refresh; Browse/Add Application; hide/restore; per-app category overrides; custom categories; local durable preferences; Help and About. Native keyboard navigation and VoiceOver labels are required. No accounts, network access, analytics, app deletion, installer management, cloud sync, automatic updater, global shortcut, or upstream settings migration in this milestone.

Default proposal: macOS 27.0+, Apple silicon, current installed stable Swift 6.4.2 in Swift 6 language mode. Broader OS support is separate scope and requires runtime evidence. Propose direct distribution rather than the Mac App Store. These are recommendations, not previously approved requirements.

## Approaches considered

| Approach | Benefit | Trade-off | Decision |
| --- | --- | --- | --- |
| Extend upstream app-menu | Reuses an existing product and its behavior | Inherits code structure and requires upstream source review and MIT notices for reused material | Not selected |
| Native SwiftUI + AppKit rebuild | Focused discovery and preference model, native menu behavior | Reimplement and verify launcher behavior | Selected by user |
| Pure SwiftUI menu implementation | Small API surface | Less direct control over native menu tracking and dynamic rebuilding | Alternative within rebuild; prefer isolated AppKit menu adapter |

## User behavior

- Click the menu-bar icon to see alphabetized category submenus, each with alphabetized visible apps. Empty categories are omitted. Standard menu type selection and arrow/return keys work.
- Menu commands: Add Application…, Manage Applications…, Refresh Applications, About SK's App Menu, Help, Quit. Scanning status and partial-scan warnings are visible without blocking launching.
- Manage Applications provides a searchable list with app name, category, location, visibility, and availability; filters All / Visible / Hidden / Missing. The window allows Show/Hide, category selection, Use Automatic Category, and Locate for missing items.
- Add Application opens a native application picker. Cancel has no effect. Validate the selected bundle; an already known app selects the existing record instead of duplicating it. Adding a hidden app does not silently unhide it; offer Show explicitly.
- Hiding is reversible and only changes the menu. Category changes persist across scans and relaunch. Manage Applications remains reachable even if every app is hidden.
- Category management supports creating and renaming custom categories. Trim whitespace, reject empty names, match duplicates case-insensitively. Built-in categories cannot be renamed or deleted. Deleting a custom category requires confirmation and resets its assignments to Automatic; never alters installed apps.
- Launch the exact selected app URL through NSWorkspace; show actionable errors for removed, inaccessible, or rejected apps. No shell execution or Gatekeeper bypass.
- Closing a management/help window keeps the menu app running. No Dock icon during normal menu-bar use; explicitly activate management windows when requested. Quit stops all scan work.

## Discovery and classification

Default roots: `/Applications`, `/System/Applications` (including Utilities), and `~/Applications` when present. Scan ordinary nested folders recursively with FileManager, skip hidden files and package contents, explicitly stop descent at every `.app`. A valid application bundle needs APPL package type and a usable executable; missing optional category/name metadata does not exclude it. Exclude this app's own installed bundle and agent/background-only bundles from automatic discovery; allow explicit manual selection of a valid app with a warning if it has no normal UI.

Never traverse directory symlinks or Finder aliases automatically. Manually chosen application aliases may resolve to their target once, with target validation. Standard and manual locations may overlap; deduplicate by resolved location/file identity, not app name. No arbitrary shallow recursion limit. Do not scan the full disk or all external volumes; an app outside the roots is added explicitly. A missing user Applications folder is normal; an unreadable existing root creates a partial result warning.

The scanner runs outside MainActor on a serial background worker, with cancellation and one active scan. Refresh requests coalesce. UI consumes immutable value snapshots; AppKit objects stay on MainActor. Keep the previous snapshot usable until a scan publishes. A generation token rejects stale scan results. Merge against current user preferences at publication so an in-flight scan cannot undo a hide or category change. Failed roots retain previous entries marked unverified rather than pretending their apps were removed.

Classify by `LSApplicationCategoryType` using a bundled deterministic mapping to readable built-in categories; missing/unknown metadata maps to Other. No guessing from folder names, online service, or AI. User override wins over automatic category. A custom category has a UUID independent of its editable name.

## Identity and persistence

AppRecord has a stable UUID, bundle identifier if present, last URL, file identity/bookmark, discovered category, origin flags (automatic/manual), display metadata, and availability. Preference records reference its UUID and store hidden state and optional category UUID. Keep separate copies of the same bundle identifier at different locations as distinct selectable apps and disambiguate duplicate display names by location/version.

Reconciliation order: resolved bookmark/file identity, then canonical URL; an unmatched new location can inherit an old record only when a single missing record and single new record share a bundle identifier. Ambiguous matches require Locate; never merge two installed copies by identifier alone. No identifier: use bookmark/path, require Locate after untrackable moves. A stale bookmark is renewed after successful resolution. Missing apps retain preferences and manual entries, are absent from the launch menu, and appear in Manage Applications. Removing a manual reference does not delete the app; if still under a scan root it remains auto-discovered. Hide is the way to suppress it.

Store one versioned Codable JSON document in the user Application Support directory under `com.siveesh.sksappmenu`, containing app identity records, overrides, custom categories, manual bookmarks, and schemaVersion. Persist user edits through a serial storage actor with atomic replacement and a last-known-good backup. Persist identity updates after scans without dropping preferences. Treat installed app metadata as read-only. Settings paths/bookmarks are private and never logged publicly.

Load errors preserve the original file and enter a clearly labeled recovery/read-only state; do not overwrite it with defaults. Offer recovery from the backup or an explicit confirmed reset that archives the original. Newer schema versions remain read-only. On write failure retain unsaved changes in memory, show a persistent warning and Retry, and never claim they are saved. Bound stores and validate record references on load.

## Modules and data flow

| Module | Responsibility | Validation |
| --- | --- | --- |
| App shell | Lifecycle, status item, window activation, Help/About | Launch/window/quit checks |
| DiscoveryService | Root enumeration, bundle validation, cancellation, partial errors | Fixture filesystem tests |
| CatalogReconciler | Identity, copy disambiguation, missing records | Pure value tests |
| CategoryResolver | Metadata mapping and overrides | Mapping/precedence tests |
| PreferencesStore | Serialized versioned persistence and recovery | Temporary-store tests |
| CatalogModel (MainActor) | Snapshot merge, editing state, operation errors | Stale result/edit race tests |
| MenuController | NSStatusItem/NSMenu adapter and launch actions | Native menu keyboard/VoiceOver checks |
| Management views | SwiftUI management and category editing; NSOpenPanel adapter | End-to-end manual scenarios |
| Launcher | NSWorkspace exact-URL launch and failure handling | Adapter tests and controlled runtime checks |

Flow: startup loads store → background scan → reconcile identities → merge current overrides → publish catalog → native menu and SwiftUI management. User edits → model revision → serialized atomic save → menu refresh. Defer menu rebuilding while a menu is tracking; apply new snapshot on close/reopen. No filesystem scanning inside menu-opening callbacks. Fetch/cache icons lazily by location and metadata revision; avoid eagerly decoding every icon at startup.

## Security, distribution, and resources

Recommend an unsandboxed direct-distribution utility with Hardened Runtime for release; read only selected/default application locations, write only own settings. No root access, Full Disk Access, Accessibility automation, Apple Events, or network entitlement required by the design. Normal filesystem privacy restrictions still apply; report denied access. App Sandbox/App Store is a different distribution choice requiring explicit scoped access and a feasibility revisit.

Use system controls/materials for macOS appearance. Include layered Icon Composer source and flattened icon export before release; create original branding. Consult the Relay About reference before implementing About, use only verified reusable assets, and provide docs/Help.md linked from Help. No third-party package dependency planned. Upstream is a behavioral reference; any reused code/assets require retaining applicable licence notices. Do not install over or modify the existing app-menu.

## Milestones and acceptance

1. Architecture: user reviews this document; approved by Siveesh on 2026-11-14.
2. Feasibility: recommendation and constraints documented; user approval required.
3. Implementation: core scanner/store/reconciler first; then menu and management; then Help/About/branding. Small increments with focused evidence.
4. QA/performance: verify nested Photoshop/Resolve fixtures plus real installed apps when available; restart persistence; unreadable roots; malformed metadata; duplicate copies; moved/missing apps; corruption/write failure; stale scan results; keyboard/VoiceOver; native light/dark appearance.
5. Documentation: build/configuration/help, known limitations, changelog, verification, session handoff, and release readiness. Signed/notarized DMG only after evidence and signing access.

Provisional targets, to measure rather than claim: menu opens within 100 ms once catalog is ready; fixture scan of 1,000 bundles within 5 seconds on the development Mac; no continuous scan timer or idle scan CPU. Record setup and measured memory rather than inventing a memory budget. An oversized or slow scan must remain cancellable and UI-responsive.

## Builder discretion and risks

Builder may choose file organization, private protocol names, test framework, and small UI spacing. Prefer an Xcode app target plus test target; no project generator dependency needed. Revisit design for permissions that prevent discovery, ambiguous identity reconciliation, or an API requiring a changed entitlement. Runtime compatibility is unverified until the app is built and exercised. The upstream missing-app cause has not been source-validated; recursive discovery is a requirement-driven design.

## Approved interface refinement — 2026-11-14

User requested icons beside app menu listings and a narrower menu fitted to content and shortcuts. Attach cached native app icons before submenu layout; use concise status/action titles and parent-folder disambiguation. Native intrinsic menu sizing remains; unusually long names are elided to a 240-point text budget, with full names/paths in tooltips and Manage Applications. Add exposes Cmd-O alongside existing management/refresh/help/quit equivalents. This is an authorized UI refinement, not a new approval gate.

## 1.0.1 startup and icon correction — 2026-11-14

User reported default management-window opening and absent app icons despite assigned images. SDK NSMenuItem.h and Apple's preferredImageVisibility reference confirm macOS27 defaults image visibility to Automatic and typically hides images. Set each application row to .visible explicitly; do not change global macOS preferences. The new real-menu regression failed with Automatic(rawValue0) versus Visible(rawValue1), then passed. All32 Xcode tests pass; result bundle Test-SKsAppMenu-2026.11.14_11-53-30-+0300.xcresult. Prior final handoff was launched with --manage; normal launch now omits that flag and every utility scene disables restoration as well as suppressing default launch. Explicit management access remains in the menu.

Sources: https://developer.apple.com/documentation/appkit/nsmenuitem/preferredimagevisibility and https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:). No new framework, entitlement or storage change. Release version1.0.1, build2. Logs retained in Build/Evidence. Native startup verification and package results are appended after observation.

## Dock launcher addendum — Proposed, approval pending

The user selected a categorized launcher window. See [Dock launcher design](superpowers/specs/2026-11-14-dock-launcher-design.md) for the reviewable behavior, sizes, lifecycle and persistence contract. Proposed optional same-app Dock visibility (default off), shared catalog/preferences, dedicated singleton launcher and Compact/Comfortable/Spacious layouts. Existing1.0.1 architecture remains approved; this extension is not approved for implementation yet.

## Authorized iOS discovery correction —2026-11-14

User requested confirmed iOS-on-Mac bundles in iOS Apps rather than warning entries. Resolve flat iOS metadata/executables and Wrapper/WrappedBundle payload metadata, require positive iOS markers and APPL/executable validation, enforce payload containment, keep outer installed URL for launch/icon/identity, and preserve manual category/visibility overrides. Missing/unreadable/ambiguous/non-iOS wrappers continue to warn. This scanner compatibility correction is authorized by the direct user request; Dock design approval remains separate/pending.

##1.0.3(5) category tooltip refinement —2026-11-14

User requested disabling category hover tooltips. Removed only the category-heading toolTip assignment; app name/path tooltips and status-icon description remain. Existing approved menu architecture and native API suffice; no new dependency/storage change, design approval or separate unit test needed for this reversible UI-only refinement. Menu rendering regression test passed through Xcode (one focused test). Prior full37-test result remains the1.0.2 baseline; no new full-suite claim. Source review confirms category headings use the default nil tooltip. Dock design remains pending approval.

## Dock addendum approved —2026-11-14

Siveesh verified and approved the categorized Dock launcher design and requested a unique Liquid Glass/dark-mode-compatible app icon. The linked Dock design is now approved; proceed to implementation and measured QA. Optional Dock remains off until the user enables it. Existing app/catalog protections and menu icon/tooltip corrections remain required.

## Refresh warning visibility —2026-11-14

Direct user-authorized small preference extension: provide a persistent, reversible Hide Refresh Warnings option for the menu and Dock launcher. Keep raw diagnostics available in Manage Applications; suppression affects scan notices only. Preserve save/recovery/Dock/launch errors and existing identities/preferences. Builder default: hideRefreshWarnings=false so existing behavior remains until changed. Prefer one shared boolean in the schema1 optional presentation block over a session-only dismissal or per-warning rules. No scanner behavior or app validation changes.

## Grid launcher and Developer ID signing —2026-11-14

User requested replacing Dock launcher rows with an icon grid; retain existing sidebar/search/shared visibility, three saved sizes and exact-copy launch. Use native SwiftUI LazyVGrid in a bounded scroll view. Names below icons (two lines with full tooltip), native selected tint, adaptive columns on resize. Compact/Comfortable/Spacious use40/56/72px icons and96/112/144px minimum cell widths. Arrow navigation moves by actual visible column count, Return launches selection; empty/filtered data must be safe. Root builder chooses these sizes; no persistence/schema changes.

User explicitly chose available Developer ID Application certificate for updated package. Keep Debug/test ad-hoc for reproducibility; package with Developer ID + Hardened Runtime + secure timestamp and verify actual authority/team. Developer ID signing and notarization are separate; notarization not requested or claimed. Never export keys. Diagnose reported macOS file-not-found dialog during Codex test relaunches; do not suppress genuine app errors or change scanner without reproduction.

## Grid hiding and automatic uninstaller visibility —2026-11-14

Direct user-authorized extension: grid context menu Hide Application shares model visibility with menu, is disabled for read-only catalog and never launches/deletes an app. Manage restores hidden apps. Apps with case-insensitive Uninstall substring in display name default hidden, including legacy entries currently visible. Track whether visibility was explicitly chosen so restore remains durable and defaults can follow renamed apps. New optional-in-decoding visibilityIsUserSet boolean is persisted per record; no schema bump. Legacy hidden=true preserves explicit hiding, legacy false adopts new default. Previously explicit visible uninstallers cannot be distinguished from old defaults; the direct request authorizes this one-time change and user can restore after upgrade. Preserve all other IDs/categories/hidden choices.

Window-control investigation: user confirmed purple screen-sharing icon; prior native AX snapshots expose Window sharing. This is macOS capture UI during inspection, not a custom app button. Keep native titlebar controls and OS privacy indicators; document Cmd-W/Cmd-M and ending sharing to restore normal presentation. No titlebar or permission changes.
