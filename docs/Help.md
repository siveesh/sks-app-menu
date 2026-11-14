# SK's App Menu Help

Open the grid icon in the menu bar to browse your applications by category. Category and application names are alphabetized. Use arrow keys to navigate and Return to open the selected app. Standard menu type selection is available.

## Dock launcher

Choose Show in Dock from the menu-bar menu or Manage Applications → Appearance to enable the Dock icon. Enabling it opens a categorized launcher; clicking its Dock icon reopens the same window, including when minimized. Choose Open Launcher to use the window even with Show in Dock off. Disabling Show in Dock closes the launcher; the menu bar stays available.

Select All Applications or a category, then search by name, category, or location. Click an app to open it, or select a row with the arrow keys and press Return. Both launchers share the same visibility and category settings. Choose Compact, Comfortable, or Spacious in the toolbar or Appearance; the choice is saved. Resize the window independently. Manage Applications opens only when requested.

## Find and add applications

Refresh Applications scans /Applications, /System/Applications, and your personal Applications folder. Ordinary vendor folders are searched recursively. Hidden folders, directory links, aliases, and apps embedded inside another app are skipped. Missing optional metadata puts an app in Other.

Choose Add Application… to browse for a valid application bundle anywhere else. Cancel leaves your catalog unchanged. Adding an app already in the catalog selects its existing record; a hidden app stays hidden until you turn on Show in menu. Manually adding a background app displays a notice because it may have no window.

## iOS Apps

Installed iPhone and iPad apps running on Apple silicon are listed under iOS Apps. Their wrapped payload metadata is read while their outer installed app is used for icons and launching. Genuine unreadable or malformed apps still produce warnings. You can hide these apps or override their category just like Mac apps.

## Manage visibility and categories

Choose Manage Applications… and search by name, location, or category. Use All, Visible, Hidden, or Missing to filter. Select an app to inspect its full location and version. Turn off Show in menu to hide it from both launchers; turn it on to restore it. Hiding never deletes or changes an installed app.

Select a category for a lasting override. Use Automatic Category restores classification from the app's metadata. Open Categories to create a custom category, select one and enter a new name to rename it, or delete it after confirmation. Built-in categories cannot be renamed or deleted. Deleting a custom category returns its assigned apps to Automatic.

## Missing apps and copies

Missing apps remain in Manage Applications with their preferences. Choose Locate Application… to reconnect a moved app. Separate copies at different locations remain independent, even when they share a name or bundle identifier. Duplicate names in the menu include their location. An inaccessible scan location retains its previous entries as Not verified; check the refresh warnings before assuming an app was removed.

## Refresh warnings

Choose Hide Refresh Warnings in the menu-bar menu or Manage Applications to hide scan notices from the menu and Dock launcher. You can also choose Hide on the launcher's refresh-warning banner. The setting is remembered across refreshes and restarts. Clear it to show notices again.

Refresh warning details remain in the collapsed Refresh warnings section at the top of Manage Applications. Hiding them does not change scanning or application validation. Storage, recovery, Dock, and launch-error notices still appear.

## Saving and recovery

Preferences are stored locally in your Application Support folder under com.siveesh.sksappmenu. There are no accounts, analytics, or network services. An unsaved-changes warning means the latest changes are still in memory; use Retry and resolve the reported storage problem before quitting.

A catalog that cannot be loaded is preserved and opens read-only. Manage Applications offers confirmed Restore Backup or Archive and Reset. Recovery may lose edits made after the backup. Reset archives the original catalog and starts fresh preferences. Neither action modifies installed applications. Newer-format catalogs may require a newer app version.

## Launching and closing

Applications open through macOS using the selected copy's exact location and normal security checks. If opening fails, read the notice, check the location, and use Locate if the app moved. SK's App Menu never bypasses macOS security checks.

Closing Manage, Categories, About, or Help leaves the menu-bar app running. Choose Quit SK's App Menu to stop it. During a refresh, the previous catalog remains usable and changes to visibility or categories are preserved when results arrive.
