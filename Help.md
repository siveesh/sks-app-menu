# SK's App Menu User Guide

SK's App Menu is a native application launcher for macOS 27 or later on Apple silicon. It organizes installed applications into categories, offers a menu-bar launcher and an optional Dock grid, and lets you choose which applications appear and where they belong.

There is no account to create. Your catalog and preferences stay on your Mac. Hiding, categorizing, adding, or locating an application changes the launcher catalog; it never deletes or modifies the installed application.

## Install and open the app

Download the latest DMG from [GitHub Releases](https://github.com/siveesh/sks-app-menu/releases). Open the disk image, drag **SK's App Menu.app** to **Applications**, and eject the image. Launch the copy in Applications. Keep the original ApplicationMenu app separate if you still use it.

The current public build is signed with Siveesh Kodapully's Developer ID and Hardened Runtime. **It is not notarized.** macOS Gatekeeper may prevent a downloaded copy from opening. Signing and notarization are different checks; a notarized release is needed for normal public-download Gatekeeper approval. Do not disable Gatekeeper or remove quarantine attributes to work around this. The developer setup guide is available in the repository under docs/Notarization.md.

On first launch, look for the small grid icon in the macOS menu bar. No management window opens automatically. The Dock icon is off by default. Applications are scanned at startup; the previous catalog remains usable while a refresh runs.

### Install with Homebrew

The project provides its own tap. This is separate from Homebrew's official cask catalog and carries the same unnotarized-release limitation as the DMG.

```bash
brew tap siveesh/tap
brew trust --cask siveesh/tap/sks-app-menu
brew install --cask siveesh/tap/sks-app-menu
```

These commands target Homebrew 7. Review the cask in the project's Casks directory before trusting it. Trust permits Homebrew to load this specific cask; it does not bypass Gatekeeper. Older Homebrew versions may not have the trust command.

After installation, open SK's App Menu from Applications. Homebrew does not start the app automatically. If a cask check or Gatekeeper blocks this unnotarized release, use a future notarized release rather than bypassing the check.

### Update an existing installation

Quit SK's App Menu before replacing it. Download the new DMG and replace only the previous SK's App Menu.app in Applications. Your catalog is stored separately, so updating the app preserves its preferences. For Homebrew installations, use the normal upgrade command.

```bash
brew update
brew upgrade --cask siveesh/tap/sks-app-menu
```

## Use the menu-bar launcher

Click the grid icon in the menu bar. Categories and applications are alphabetized. Point to a category to open its submenu, then click an application. Each application has its native icon. Arrow keys and Return work with the native menu, and typing an application's name can help select a menu item.

App names may be shortened to keep menus compact. Hover an application to see its full name and location. Separate copies with the same name are distinguished by their containing folder. Category headings intentionally have no hover tooltip.

The menu also provides these commands:

- **Open Launcher… — Command-L:** open the categorized grid window.
- **Show in Dock:** enable or disable the Dock icon and launcher behavior.
- **Add Application… — Command-O:** browse for an application bundle.
- **Manage Applications… — Command-comma:** open catalog and appearance controls.
- **Refresh — Command-R:** rescan application folders.
- **Hide Refresh Warnings:** show or suppress scan notices in the launchers.
- **About…:** view product version, developer identity and contact links.
- **Help:** open this bundled user guide.
- **Quit — Command-Q:** stop the app, including its menu-bar and Dock presence.

Loading, refreshing, recovery, save, Dock, or scan notices can appear above the categories. A notice is a route to more information; it is not an application entry.

## Enable and use the Dock grid

Choose **Show in Dock** in the menu-bar menu, or open **Manage Applications → Appearance** and enable its checkbox. The Dock icon appears and the launcher opens. Once enabled, launching SK's App Menu again opens the grid; clicking its Dock icon reopens or restores the same launcher window, including when minimized.

You can choose **Open Launcher…** without enabling the Dock icon. Disabling Show in Dock closes the launcher window and leaves the menu bar available. Closing the grid with Command-W does not quit the app. Manage Applications still opens only when requested.

### Browse categories and search

Select **All Applications** in the sidebar to see all visible, non-missing apps, or select a category to narrow the grid. Use the toolbar search to match application names, category names, or locations. Search is limited to the selected category; choose All Applications to search the whole visible catalog.

Click a tile to open that exact installed copy. Full names and paths appear on hover. To use the keyboard, focus the grid, move the selection with arrow keys, then press Return. Up and Down follow the displayed columns. The selection stays within the available tiles. Hidden or missing applications do not appear in the grid.

If no applications match, clear the search, choose another category, or use Manage Applications to inspect hidden and missing entries.

### Choose a display size

Use the **Display size** picker in the launcher toolbar or **Launcher size** in Manage Applications. **Compact** fits more apps, **Comfortable** is the default balance, and **Spacious** provides larger icons and labels. The selection is saved and shared between the two controls.

Resize the window independently of this choice. Grid columns adapt to the available width, and long names use up to two lines. Toolbar items may move into an overflow menu when space is limited.

### Launcher toolbar and notices

The sidebar button hides or shows category navigation. The remaining toolbar controls choose display size, refresh the catalog, add an application, open Manage Applications, and search. Refresh and Add are disabled when the catalog cannot be edited.

A refresh-warning banner has **Hide** and **Manage…** actions. Hide suppresses scan notices in both launchers; Manage opens the full diagnostic details. Save, recovery, Dock, and launch-error notices remain available even when refresh warnings are hidden.

## Hide and restore applications

Right-click a grid tile and choose **Hide Application**. The tile disappears from both the grid and menu-bar launcher. The catalog record remains, and nothing is uninstalled. Hiding is shared between both launchers; there is no separate grid-only hidden list.

To restore it, open **Manage Applications**, select the **Hidden** filter, select the app, and turn on **Show in menu**. Despite its label, this control restores the app to both launchers. The management list also provides right-click **Show in Menu** or **Hide from Menu** actions.

Applications whose display names contain **Uninstall**, ignoring letter case, are hidden by default. This includes names such as Uninstall Resolve and Creative Cloud Uninstaller. Existing matching entries adopt this default when upgrading from older versions. To show one, restore it in Manage Applications. That explicit choice is remembered across refreshes, restarts, and name changes.

## Manage Applications window

Open it from the menu-bar command, the grid toolbar, or a notice's Manage action. The window is for editing the catalog; it does not open automatically on normal startup.

### Appearance and warning controls

**Show in Dock** changes Dock presence. **Launcher size** changes grid density. **Open Launcher…** opens the grid. **Hide Refresh Warnings** remembers whether scan notices should appear in the launchers. Warning details remain in the collapsible **Refresh warnings** section at the top when there are any.

### Search and filters

Search by application name, location, or category. Use **All** for the whole catalog, **Visible** for non-hidden/non-missing entries, **Hidden** for entries you can restore, or **Missing** for entries not found during a scan. The count reflects the active search and filter.

Select an application in the list to show its details. Arrow-key selection is supported. Icons help identify apps, but location is the reliable way to distinguish installed copies.

### Application details and actions

The detail area shows the app's name, version when available, availability, category, full location, bundle identifier when available, and whether it was added manually. The actions include **Show in menu**, category selection, **Use Automatic Category**, **Open Application**, **Show in Finder**, and **Locate Application…** when the app is missing.

**Available** means discovery verified the bundle. **Missing** means it was not found in a completed scan. **Not verified** means the scan could not establish its status, for example because a location was inaccessible; its previous entry is retained and opening it may fail.

The toolbar provides **Add Application**, **Refresh**, **Categories**, **Help**, and search. Read-only recovery disables catalog edits to protect the saved file, while inspection and appropriate recovery controls remain available.

## Find and add applications

Refresh scans **/Applications**, **/System/Applications**, and your personal **~/Applications** folder. Ordinary vendor subfolders are searched recursively, including installations such as Adobe Photoshop and DaVinci Resolve inside named folders. Hidden folders, linked directories, Finder aliases during traversal, and apps embedded inside another app bundle are skipped to avoid duplicate helpers and unsafe traversal.

If an app is elsewhere, choose **Add Application…**, browse to its .app bundle, and confirm. Cancel leaves the catalog unchanged. The selected bundle is checked before it is added. Adding a copy already in the catalog selects its existing record; it does not create a duplicate or automatically restore a hidden app.

Manually added apps remain part of later refreshes even outside the standard roots. A background-only or agent app may be added explicitly, with a notice that it may not show a window. An invalid or unreadable bundle produces an explanation rather than a launchable entry.

## Change application categories

Select an app in Manage Applications and use **Category**. Choose a built-in or custom category for a saved override. The menu and grid update to use it. Refreshing metadata does not erase an override.

Choose **Automatic** or **Use Automatic Category** to return to metadata-based classification. When metadata has no recognized category, the automatic category is **Other**.

### Create, rename and delete custom categories

Open **Categories** from the management toolbar. Enter a name and choose Create to create a custom category. Select a custom category, edit its name, and use Rename Selected to change it. Names must be nonempty, distinct from existing categories, and within the displayed validation rules.

Built-in categories cannot be renamed or deleted. Deleting a custom category requires confirmation and returns its assigned apps to Automatic classification. It does not hide, delete, or uninstall those apps.

## iPhone and iPad applications

Compatible iPhone and iPad apps installed on Apple silicon appear in **iOS Apps** by default. Their installed wrappers are used for icons and launching, while discovery reads the contained iOS metadata. You can hide or recategorize them just like Mac apps, and explicit category overrides win.

An inaccessible or malformed bundle is still reported as a warning. A warning does not by itself prove an app is an iOS app. The current validator requires normal application metadata; unusual system packaging, including the native Passwords bundle on the development host, may be excluded and reported.

## Moved, missing and duplicate copies

Missing apps remain in Manage Applications with their identity and preferences. Select the **Missing** filter, select the app, and choose **Locate Application…** to point to its new bundle. A successful reconnection keeps that record's visibility and category choices.

If the selected location already has a separate catalog entry with conflicting preferences, the app asks before reconnecting and replacing that duplicate entry's settings. Cancel keeps the catalog unchanged. An ambiguous move is not guessed automatically.

Separate physical copies at different locations remain independent even if their names and bundle identifiers match. Use the detail path or Show in Finder before launching or editing the wrong copy. A scan failure retains affected prior entries as Not verified instead of silently removing their preferences.

## Refresh warnings and launch errors

Choose **Refresh** after installing, moving, or removing applications. The app also scans on startup; it does not continuously watch every folder. During a refresh, the previous catalog remains usable, and changes to visibility and categories are retained when results arrive.

Use **Hide Refresh Warnings** or the banner's **Hide** action to suppress scan notices from both launchers. This setting survives restart. Clear it to show notices again. Details stay in Manage Applications → Refresh warnings. Hiding notices does not change discovery, validation, or the underlying warnings.

Applications open through macOS using the selected copy's exact URL and normal security checks. If opening fails, inspect the notice, check its location, and use Locate if it moved. A launch-error notice can offer Manage Applications or OK. The app does not bypass macOS security checks.

## Saving, backups and recovery

Preferences are saved locally and automatically. They include catalog identities, manual locations, visibility choices, category overrides, custom categories, Dock presence, grid size, and refresh-warning visibility. No accounts, online analytics, or cloud synchronization are used.

```text
~/Library/Application Support/com.siveesh.sksappmenu/
```

The primary file is **catalog.json**, and **catalog-backup.json** holds a previously valid saved state. Recovery archives use distinct names in the same folder. If you make a manual backup, copy the entire settings folder while the app is quit. Do not edit its JSON while the app is running.

### Unsaved changes

If saving fails, an **Unsaved Changes** notice remains visible. Your latest edits may still exist only in memory. Use **Retry** in Manage Applications after resolving the storage problem. Quitting waits for pending saves; if saving still fails, a confirmation lets you cancel quitting or discard unsaved work.

### Read-only recovery

If a catalog cannot be read or validated, the original is preserved and editing is disabled. This prevents an unreadable file from being replaced by empty defaults. Manage Applications offers **Restore Backup…** and **Archive and Reset…**, each with confirmation.

Restore Backup uses the saved valid backup; edits made after that backup may be lost. Archive and Reset preserves an archived copy of the original and starts fresh launcher preferences. Neither recovery action changes installed apps. Newer-format settings may require a newer app version.

## Window controls and closing

Use the normal macOS close, minimize and zoom controls. **Command-W** closes the current window and **Command-M** minimizes it. Closing the launcher, management, categories, Help, or About window leaves the app running. Choose Quit or Command-Q to stop it.

During window capture or screen sharing, including visual testing, macOS may replace the traffic-light buttons with a purple **Window sharing** control. This presentation belongs to macOS, not SK's App Menu. Standard window shortcuts remain available. When capture ends, macOS normally restores its standard controls; the app does not suppress the sharing indicator.

## Help, About and keyboard reference

With an app window active, choose **Help → SK's App Menu Help**. The menu-bar launcher's **Help** command and the management toolbar's **Help** button open the same bundled guide. Use the guide window's **Contents** menu to jump to a topic. Links open in your normal browser; code and paths can be selected and copied.

**About…** shows the app icon, version and build, developer identity, website, and contact link. It is separate from catalog management and does not change preferences.

- **Command-L:** Open Launcher.
- **Command-comma:** Manage Applications.
- **Command-O:** Add Application.
- **Command-R:** Refresh.
- **Command-W:** Close the current window.
- **Command-M:** Minimize the current window.
- **Command-Q:** Quit, with unsaved-work handling when needed.
- **Arrow keys and Return:** Navigate and open menu items or selected grid apps.

There is no global system-wide launcher shortcut, login-item control, or automatic updater in this release. These commands work while interacting with the app or its menu.

## Troubleshooting and support

**An application is absent:** Refresh, choose All Applications, clear search, inspect Hidden/Missing in Manage Applications, then Add or Locate as appropriate. Check whether its name contains Uninstall. Review scan warnings for unreadable or unusual bundles.

**A category change seems missing:** Confirm that the selected physical copy is the one you intended. Search the full path and inspect Category in Manage Applications. Use Automatic only if you want metadata-based classification again.

**The Dock icon is absent:** Enable Show in Dock. You can still use Open Launcher without it. Closing the grid keeps the app alive; quitting stops both launchers.

**The app is running but no window appears:** Check the menu-bar grid icon. This is normal with Dock disabled. Open Launcher or Manage Applications when required.

**The download does not open:** Check the release's notarization status. The current release is Developer ID-signed but unnotarized, so a Gatekeeper rejection is a release qualification limitation, not a reason to disable system protections.

**Report a problem:** Use [GitHub Issues](https://github.com/siveesh/sks-app-menu/issues). Include the app version/build from About, macOS version, what you expected, what happened, and reproducible steps. Redact private file paths and catalog contents before attaching anything. Never send passwords, signing keys, or other credentials.

## Uninstall and preserve preferences

Quit the app, then remove SK's App Menu.app from Applications. For a Homebrew installation, use the cask uninstall command. This does not uninstall the applications that SK's App Menu lists.

```bash
brew uninstall --cask siveesh/tap/sks-app-menu
```

The app's settings folder is intentionally retained so reinstalling can recover preferences. Removing that folder yourself erases launcher settings; back it up first if you may need it. Neither normal app removal nor the cask deletes your installed applications, documents, or original ApplicationMenu app.
