# Optional Dock launcher — design

Status: Approved by Siveesh on2026-11-14.
Date: 2026-11-14. Existing released local milestone:1.0.1(2),32 tests.

## Intent and selected approach

User requested a Dock interface comparable to the menu-bar launcher, with Compact, Comfortable and Spacious display options. User selected a categorized launcher window on2026-11-14 over a popup matching the menu bar. Implement as an optional mode of the same SK's App Menu app and same running process/catalog. A separate executable would add duplicate-instance and shared-store coordination with no user benefit for this feature.

The user verified and approved this design to proceed on2026-11-14, additionally requesting a unique dark-mode-compatible Liquid Glass app icon.

## Scope and interaction

- Add a Show in Dock toggle, initially off for new/existing installations, accessible from the status menu and a small Appearance section in the management window. The menu-bar icon remains available in both modes.
- Turning Dock on adds this app's existing icon to the Dock and opens its launcher. Turning Dock off removes the running Dock presence and closes the launcher; other management/help windows can remain open.
- When Dock mode is on, opening the app initially or clicking its Dock icon opens/raises one Launcher window. A minimized launcher is restored. A second window is never created. Manage Applications is not opened automatically.
- When Dock mode is off, normal launch remains menu-bar-only. Offer Open Launcher… in the status menu for explicit access without enabling permanent Dock visibility.
- Closing Launcher leaves the app running; the next Dock click reopens it. Quit retains existing save-draining and unsaved-confirmation behavior. Pinning the app using macOS Keep in Dock remains a user action; the app does not edit Dock preferences or add login behavior.
- Launcher has a native category sidebar (All Applications plus nonempty categories) and an app list with real icons and names. The toolbar contains search, display-size choice, Refresh, Add Application, and Manage Applications. Use standard macOS light/dark materials and controls.
- Search filters the selected category by app name, category or location; All Applications searches the entire visible catalog. Selecting an app button launches its exact installed copy with the existing launcher service; arrow navigation and Return provide keyboard access. Tooltips/details expose full paths for duplicate names.
- Hidden and missing apps are excluded from launching, matching menu-bar behavior. Unverified apps remain available with their current warning semantics. Manage Applications is the place to restore hidden apps or Locate missing ones. Visibility/category changes and refresh results update both surfaces immediately from the same CatalogModel.
- Starting an app activates that target; the launcher does not steal focus back. It stays available for later use. Errors are visible and actionable, with a route to management/recovery.

## Three display sizes

| Choice | Icon size | Minimum row height | App name text |
| --- | --- | --- | --- |
| Compact |20pt |32pt |13pt |
| Comfortable (default) |28pt |44pt |14pt |
| Spacious |40pt |60pt |16pt |

The choice changes icon/text size and spacing immediately and persists across relaunch. Rows may grow for accessibility rather than clipping text. The launcher remains resizable; changing density does not forcibly resize a window the user has arranged. Proposed initial window760×560pt, minimum520×360pt, clamped to the visible screen; sidebar can collapse at narrow widths. Exact small spacing and native control composition are builder discretion. Density applies to Launcher; the compact native menu remains independently sized.

## Architecture and persistence

Reuse CatalogModel.visibleApps, categoryName, scanning, app selection/picker, exact-URL launch and error handling. Add a dedicated LauncherView with category/list subviews, a LauncherDensity value type, and a narrow DockPresenceController owned by AppRuntime. Keep navigation/search ephemeral to Launcher, separate from management selection.

Use a single SwiftUI Window scene identified as launcher, default launch suppressed and restoration disabled. Explicit runtime decisions open it after preferences load. Existing utility scenes stay suppressed/nonrestoring. Extend AppDelegate's reopen handling to route Dock activation to launcher; return false after custom handling so AppKit does not open an unintended scene. If the SwiftUI openWindow relay is not ready, queue one pending open request and drain it when registered.

DockPresenceController requests .regular/.accessory on MainActor via setActivationPolicy and checks its Boolean result. If a transition fails, keep the prior effective preference/policy and display an error. Never silently report Dock enabled when policy change failed. Avoid NSWindow creation in the delegate; use a narrow window bridge only if needed to restore a minimized scene.

Extend CatalogDocument with a presentation block containing showInDock and launcherDensity, decoded with defaults when absent. Existing schema1 app/category records remain valid and unchanged. Missing or unknown density defaults to Comfortable; absent Dock preference defaults off. Continue serialized revision-based saves, atomic replacement and last-known-good backups. Scans must preserve current presentation settings. Recovery restores presentation values from the selected backup, or safe defaults for an older backup, with the existing warning about newer unsaved changes. An older binary may ignore/drop the new optional presentation values on its next save, but must not lose existing catalog records. Do not overwrite corrupt/newer stores or bypass read-only recovery to save appearance choices.

No additional process, helper, network service, permissions or runtime dependency. Existing LSUIElement launch classification may remain; verified runtime activation policy governs optional Dock visibility.

## Feasibility and alternatives

Native SwiftUI Window/List/NavigationSplitView plus existing AppKit lifecycle is recommended. Apple documents dynamic activation policies and Dock-driven reopen callbacks. SwiftUI launch behavior alone is insufficient for routing every Dock click, especially when management is visible; explicitly handle the reopen event. A Dock popup was considered but the user selected a categorized window. A second app/binary was considered and rejected for coordination/maintenance cost.

A local implementation is feasible with the current macOS27/Swift6.4.2 toolchain. Runtime validation is required for dynamic Dock transitions, first launch and minimized-window reopening. The current menu icon visibility fix (preferredImageVisibility=.visible) must remain intact. Public signing/notarization limitations do not change.

Primary sources verified2026-11-14:
- https://developer.apple.com/documentation/appkit/nsapplication/setactivationpolicy(_:)
- https://developer.apple.com/documentation/appkit/nsapplicationdelegate/applicationshouldhandlereopen(_:hasvisiblewindows:)
- https://developer.apple.com/documentation/swiftui/scene/defaultlaunchbehavior(_:)
- https://developer.apple.com/documentation/swiftui/scene/restorationbehavior(_:)

## Milestones and acceptance

1. Architecture/feasibility: approve this addendum, including optional same-app Dock mode and the size table.
2. Implementation: backward-compatible presentation preferences, Dock lifecycle adapter, native launcher and controls, then Help updates.
3. QA: old catalog fixtures still load with identical app IDs/hidden/category settings; all three densities round-trip; scan/edit races retain presentation settings; failed activation/save stays honest; no duplicate scans or windows.
4. Native runtime: default-off launch opens no utility windows; enabling Dock shows icon/Launcher; clicking/restoring/reopening Dock uses the same window even with management open; turning off returns to menu-bar-only; icon/keyboard/search/launch work in all sizes; Quit drains saves.
5. Documentation/package: update verification, QA, Help, changelog and handoff; preserve current32 tests; add relevant regressions; make a new local package only after evidence. No build/test/installation claim for this feature yet.

No new reusable lesson identified in this design phase; lessons bridge reviewed without inventing a correction.

## Independent builder review

Read-only review on2026-11-14 reported “nothing important left unanswered”; same-app lifecycle, density choices and backward-compatible defaults are sufficient for implementation planning. Detailed addendum approved2026-11-14.

## Approved branding addition

Create an original recognizable multi-layer Icon Composer app icon with source assets and a flattened preview. Verify native compilation and contrast/readability in default/dark/tinted presentation. Reuse the same app identity in Dock, Finder and About. Keep the status-menu glyph legible as a template symbol.
