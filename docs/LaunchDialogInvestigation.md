# Codex relaunch dialog investigation

Date: 2026-11-14. Scope: the native macOS “file can't be found” dialog reported during Codex-driven testing, separate from normal app startup. No production source change selected.

## Observed evidence

- The owner clarified that the dialog occurs when Codex relaunches the app to test functions, rather than when they start it manually.
- Root's recorded action at 12:53:49–50 was the first CUA `getApp` call with the Debug bundle's full path, following a successful explicit script build/launch. No bundle staging or replacement happened at that time.
- At 12:53:49.035, LaunchServices logged `Failed to register <private> trusted: NSOSStatusErrorDomain/-67062`. The native `security error -67062` command identifies this as “code object is not signed at all.” The logged path is private, so this line alone cannot identify the exact object.
- At 12:53:50.654, Finder's DesktopServices CopyEngine logged `TranslateRawPOSIXError [2: No such file or directory] -> -43 (fnfErr - File not found), path: N/A`. This is a native file-not-found event at the reported testing time; the unavailable path prevents identifying the exact missing target.
- Adjacent app registration records identify `com.siveesh.sksappmenu`. “Launch-disabled” registrations on behalf of PID589 were Spotlight metadata indexing (the process is `mds`); they do not independently prove a launch rejection.
- Raw relevant native log extract: `Build/Evidence/grid-launch-dialog-investigation.log` (ignored evidence artifact).
- Read-only standalone production scanner/store probe: 149 apps, no failed roots, no manual or unavailable records, successful catalog load; the only scanner warning was Passwords.app's non-APPL package type. `~/Applications` exists. No file-not-found warning was reproduced in these inputs.
- Running app 1.1.1(7), its executable, Help.md, and Assets.car existed. NSWorkspace resolved the bundle identifier to that same existing Build/Testing bundle. Help resource loading has a fallback; all SwiftUI scenes disable restoration. These checks did not find a missing startup resource.
- `script/build_and_run.sh` passes the exact bundle path as one quoted `open -n` argument and app arguments after `--args`. No argument quoting defect was found.

## Inference and operational correction

The timestamp correlation supports a native test-tool app-resolution/registration problem during `getApp`, rather than a discovery or catalog failure. The precise internal native target is unproven because its path is unavailable in logs. No scanner, persistence, or production UI fix is justified by this evidence.

For further UI checks, root will finish signing and staging first, retain one stable exact bundle path, validate its executable, launch it explicitly through the quoted native open command, and wait for the running process/window before attaching UI inspection. Avoid asking `getApp` to launch or rediscover a windowless accessory app. Do not replace or move a bundle while it is the UI inspection target. Root owns final runtime verification; this investigation does not claim that the dialog has been eliminated.
