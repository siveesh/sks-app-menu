# Project Overview

`SK_PROJECT_TEMPLATE_READY: yes`

## Identity

- **Name:** SK's App Menu
- **Bundle identifier:** com.siveesh.sksappmenu (provisional)
- **Internal target:** SKsAppMenu
- **Repository slug:** sks-app-menu
- **Target platform:** macOS; minimum 27.0, Apple silicon
- **Initialized:** 2026-11-14
- **Workspace:** existing Application Menu directory, retained

## User requirements

A native rebuild of the categorized launcher experience from app-menu, compatible with macOS 27 and current Swift. Discover apps recursively in Applications vendor subfolders (including Adobe and DaVinci installations); Browse/Add an app if missed; hide/restore apps; change an app's category persistently.

## Confirmed decisions

On 2026-11-14 the user selected the native rebuild design and the name SK's App Menu. Architecture.md and Feasibility.md were explicitly approved by Siveesh on 2026-11-14 with instructions to proceed.

## Approved defaults

- SwiftUI management window plus AppKit native category menus.
- macOS 27.0+ and Apple silicon; installed stable Xcode 27.2/Swift 6.4.2 in Swift 6 mode.
- Direct distribution, unsandboxed with Hardened Runtime; no services or dependencies.
- Versioned local Application Support storage. Hiding/category changes affect launcher preferences only.
- Native keyboard/VoiceOver behavior; English first, localization-ready strings.
- No cloud, AI, telemetry, auto-updater, login item, or global hotkey in MVP.

## Constraints and success

User preferences survive refresh/restart; bundles remain read-only; traversal stops at app boundaries; incomplete scans do not erase preferences. Never overwrite the original launcher. Test evidence required before claiming compatibility. Signing credentials and public licensing decisions are not yet available/selected.

## Approved Dock feature

Optional Dock presence with categorized launcher window (user-selected approach), shared catalog and Compact/Comfortable/Spacious layouts. Detailed design explicitly approved on2026-11-14 and implemented in1.1.0. Dock is opt-in; the menu remains available. Original layered Prism Launcher icon supports native glass and dark appearances.

Confirmed iOS-on-Mac application wrappers are supported and classified in iOS Apps, while retaining outer launch URLs and existing user overrides.

Refresh warning visibility is user-controlled in1.1.1: saved Hide Refresh Warnings option suppresses scan notices in both launchers, with raw details retained in management. Other important notices remain visible.

1.2.0 replaces Dock rows with a responsive icon grid; shared categories/search and saved three-size preference retained. User explicitly authorized Developer ID signing, applied to app and DMG with Hardened Runtime/secure timestamp. Notarization remains pending. macOS file-not-found dialog during Codex relaunches investigated without speculative scanner changes; improved explicit test target and stable signed QA launch path.
