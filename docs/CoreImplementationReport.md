# Discovery and catalog core implementation evidence

Date: 2026-11-14. Scope: implementation-plan Task 1 only. Architecture and Feasibility are approved. Orchestrator implementation retrieval used `/usr/bin/python3` because the already documented default Python shim is broken. Relevant retrieved guidance: standard filesystem locations and bookmark lifecycle; current Apple category values verified in [Apple's LSApplicationCategoryType reference](https://developer.apple.com/documentation/bundleresources/information-property-list/lsapplicationcategorytype?changes=_5).

## Files owned and changed

- `Package.swift`: dependency-free MenuCore library and MenuCoreTests target, Swift 6 language mode, macOS 27 deployment target.
- `Sources/Core/CatalogTypes.swift`: Codable/Sendable catalog, app, category and scan values with public initializers.
- `Sources/Core/CategoryResolver.swift`: stable category identifiers, deterministic App Store metadata mapping, explicit game subtypes, unknown fallback, custom category names.
- `Sources/Core/DiscoveryService.swift`: iterative recursive traversal, hidden/package/app/link/alias boundaries, APPL/executable validation, background-agent exclusion, explicit alias resolution and manual warning, own-bundle exclusion, cancellation, partial failures, ordinary bookmarks and volume-qualified inode identity. Metadata reads never execute or modify installed apps.
- `Sources/Core/CatalogReconciler.swift`: unique indexed physical identity, cached bookmark resolution, then canonical path matching; unique unmatched bundle-ID relocation; preserved UUID/user edits/manual flags; missing/unverified entries retained.
- `Tests/CoreTests/CoreTests.swift`: 16 focused filesystem/value tests, including 1,000-app fixture measurement.
- This report. PreferencesStore and other integration files were not edited by this task.

## RED and GREEN

1. Initial `swift test` exited 1 because the new MenuCore target was empty; this was setup evidence, not behavioral RED.
2. Added API/value scaffolding and no-behavior scanner/category/reconciler stubs. The shared workspace then exited 1 for the independently developed PreferencesStore's missing symbol, as expected. An isolated temporary copy containing only Task 1 tests successfully built and ran: 10 tests, 27 assertion failures, zero unexpected failures. This established behavioral RED for missing discovery, metadata validation, categories, identity moves, missing/failed-root reconciliation, and manual state.
3. Implemented behavior. Two initial URL assertions compared directory URL spellings including a trailing slash; corrected fixture comparisons to filesystem paths because location equality is the required behavior.
4. A regression for one moved copy while a second copy remains installed ran RED with 2 assertions. Updated relocation to count unmatched records; GREEN.
5. A pre-cancelled empty scan ran RED with 1 assertion. Added entry and publication cancellation checks; GREEN.
6. Apple's official reference exposed an incorrect recalled healthcare category suffix. Added `public.app-category.healthcare-fitness` expectation, observed 1 failing assertion, then corrected the stable built-in ID; GREEN.
7. An application URL supplied as a scan root ran RED: scanner incorrectly found its embedded helper. Added opaque bundle handling for root packages; GREEN.
8. Final complete `swift test` at 11:33:09 local time: exit 0, **22 tests, 0 failures**, 1.019 seconds overall; 16 Task 1 tests and 6 independently authored persistence tests. No compiler warnings in that run.

## Measured fixture performance

The final test creates 1,000 real APPL bundle fixtures with executable files, under 50 vendor folders. Creation and cleanup are excluded from the printed scan/merge measurements. Development-host debug measurements from the final complete suite:

| Operation | Observed duration |
| --- | --- |
| Discovery of 1,000 bundles including metadata, bookmarks and identity | 0.339002625 seconds |
| Warm merge preserving 1,000 existing identities | 0.032400125 seconds |

These are controlled filesystem-fixture results, not real-installed-app timing or a general latency guarantee. Matching indexes avoid quadratic bookmark-resolution I/O; matching file identifiers need no bookmark resolution.

## Coverage and remaining boundaries

Verified nested vendor discovery, embedded-helper exclusion, malformed apps/executables, executable path traversal rejection, nonexecutable rejection, independent copies with duplicate names and bundle IDs, symlink and real Finder-alias boundaries, explicit alias selection, manual overlap deduplication, background/agent behavior, own-bundle exclusion, missing/non-directory roots, actual unreadable nested folders, failed-root path-component boundaries, immutable preference preservation, bookmark-based moves, unique and ambiguous bundle-ID moves, cancellation, and the application-root boundary.

Physical identity uses the volume UUID plus inode, with filesystem device plus inode fallback if a volume UUID is unavailable. This avoids inode-only cross-volume collisions; moves across volumes rely on unambiguous bundle identity or explicit Locate. Bookmarks are best effort and refreshed from newly inspected bundles. A failed nested folder conservatively marks the enclosing supplied root failed, retaining unseen prior records as unverified. Directory symlinks supplied as roots are skipped with a warning by the approved traversal policy.

This task does not establish app UI, launch, installation, packaging, signing, notarization, accessibility, or minimum-OS runtime compatibility. It schedules no background work itself; the integration model must call scan off MainActor and own generation/save coordination. No commit was created by this task.

## Reusable corrections for the phase lessons bridge

- Foundation directory URLs can carry a trailing slash; tests of filesystem location should compare normalized paths rather than incidental URL spelling.
- Count missing/new unmatched copies when relocating by bundle identifier; a still-installed matched copy is neither missing nor new.
- Check cancellation at API entry and before publishing even for an empty scan.
- Verify Apple metadata identifiers against primary references; the category suffix is healthcare-fitness.
- Apply package boundaries to supplied root URLs as well as discovered children.
