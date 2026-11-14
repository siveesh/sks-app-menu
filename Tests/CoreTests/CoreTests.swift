import Foundation
import XCTest
@testable import MenuCore

final class CoreTests: XCTestCase {
    private func fixtureRoot() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    @discardableResult private func app(_ root: URL, _ path: String, id: String? = "test.application", extra: [String: Any] = [:]) throws -> URL {
        let url = root.appendingPathComponent(path)
        let executable = url.appendingPathComponent("Contents/MacOS/Fixture")
        try FileManager.default.createDirectory(at: executable.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("#!/bin/sh\nexit 0\n".utf8).write(to: executable)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: executable.path)
        var info: [String: Any] = ["CFBundlePackageType": "APPL", "CFBundleExecutable": "Fixture", "CFBundleName": "Fixture", "CFBundleShortVersionString": "1.2", "LSApplicationCategoryType": "public.app-category.photography"]
        info["CFBundleIdentifier"] = id
        info.merge(extra) { _, new in new }
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: url.appendingPathComponent("Contents/Info.plist"))
        return url
    }

    // Catches shallow traversal, descent into bundles, and deduplication by name/identifier.
    func testNestedDiscoveryStopsAtApplicationsAndPreservesCopies() throws {
        let root = try fixtureRoot()
        let first = try app(root, "Adobe/2026/Photoshop.app")
        let second = try app(root, "DaVinci/Resolve.app")
        try app(first, "Contents/Helpers/Nested.app")
        let result = try DiscoveryService().scan(roots: [root])
        XCTAssertEqual(Set(result.apps.map { $0.url.path }), Set([first.path, second.path]))
        XCTAssertTrue(result.failedRoots.isEmpty)
        XCTAssertEqual(result.apps.first?.automaticCategory, "photography")
    }

    // Catches following symlink directories/apps and package boundaries.
    func testAutomaticDiscoverySkipsLinksHiddenPackagesBackgroundAndInvalidBundles() throws {
        let root = try fixtureRoot()
        let outside = try fixtureRoot()
        let target = try app(outside, "Outside.app")
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("Linked"), withDestinationURL: outside)
        try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("Link.app"), withDestinationURL: target)
        try app(root, ".Hidden.app")
        try app(root, "Plugin.bundle/Inside.app")
        try app(root, "Background.app", extra: ["LSBackgroundOnly": true])
        try app(root, "Agent.app", extra: ["LSUIElement": true])
        try app(root, "Wrong.app", extra: ["CFBundlePackageType": "BNDL"])
        let broken = try app(root, "Broken.app")
        try FileManager.default.removeItem(at: broken.appendingPathComponent("Contents/MacOS/Fixture"))
        let result = try DiscoveryService().scan(roots: [root])
        XCTAssertTrue(result.apps.isEmpty)
        XCTAssertFalse(result.warnings.isEmpty)
        let manual = try DiscoveryService().scan(roots: [], manualURLs: [root.appendingPathComponent("Link.app"), root.appendingPathComponent("Background.app")])
        XCTAssertEqual(manual.apps.count, 2)
        XCTAssertTrue(manual.apps.allSatisfy(\.isManual))
        XCTAssertFalse(manual.warnings.isEmpty)
    }

    func testManualOverlapDeduplicatesAndOwnBundleExcluded() throws {
        let root = try fixtureRoot()
        let first = try app(root, "One.app")
        let own = try app(root, "Own.app")
        let result = try DiscoveryService().scan(roots: [root, root], manualURLs: [first], excluding: own)
        XCTAssertEqual(result.apps.count, 1)
        XCTAssertEqual(result.apps.first?.url.path, first.path)
        XCTAssertEqual(result.apps.first?.isManual, true)
        XCTAssertNotNil(result.apps.first?.fileIdentifier)
        XCTAssertNotNil(result.apps.first?.bookmark)
    }

    func testMissingRootNormalButNonDirectoryRootPartialFailure() throws {
        let root = try fixtureRoot()
        let file = root.appendingPathComponent("ordinary")
        try Data().write(to: file)
        let result = try DiscoveryService().scan(roots: [root.appendingPathComponent("missing"), file])
        XCTAssertEqual(result.failedRoots, [file])
        XCTAssertFalse(result.warnings.isEmpty)
    }

    func testInspectRejectsTraversalExecutableAndNonExecutableFile() throws {
        let root = try fixtureRoot()
        let bad = try app(root, "Bad.app", extra: ["CFBundleExecutable": "../../../outside"])
        XCTAssertThrowsError(try DiscoveryService().inspect(url: bad))
        let noExecute = try app(root, "NoExecute.app")
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: noExecute.appendingPathComponent("Contents/MacOS/Fixture").path)
        XCTAssertThrowsError(try DiscoveryService().inspect(url: noExecute))
    }

    func testCategoryMetadataFallbackAndNames() {
        XCTAssertEqual(CategoryResolver.category(for: "public.app-category.action-games"), "games")
        XCTAssertEqual(CategoryResolver.category(for: "public.app-category.healthcare-fitness"), "healthcare-fitness")
        XCTAssertEqual(CategoryResolver.category(for: nil), "other")
        XCTAssertEqual(CategoryResolver.category(for: "not-a-category"), "other")
        XCTAssertEqual(CategoryResolver.name(for: "custom", custom: [.init(id: "custom", name: "My Apps", isBuiltIn: false)]), "My Apps")
        XCTAssertEqual(CategoryResolver.name(for: "photography", custom: []), "Photography")
    }

    func testReconciliationKeepsEditsOnIdentityMoveAndPreservesMissing() {
        let existing = AppRecord(url: URL(fileURLWithPath: "/Applications/Old.app"), name: "Old", bundleIdentifier: "test.app", fileIdentifier: "volume:a", isManual: true, hidden: true, categoryOverride: "custom")
        let missing = AppRecord(url: URL(fileURLWithPath: "/Applications/Missing.app"), name: "Missing", hidden: true)
        let moved = DiscoveredApp(url: URL(fileURLWithPath: "/Applications/New.app"), name: "New", bundleIdentifier: "test.app", fileIdentifier: "volume:a")
        let result = CatalogReconciler.merge(existing: [existing, missing], scan: .init(apps: [moved]))
        XCTAssertEqual(result.count, 2)
        let record = result.first { $0.id == existing.id }
        XCTAssertEqual(record?.url, moved.url)
        XCTAssertEqual(record?.name, "New")
        XCTAssertEqual(record?.hidden, true)
        XCTAssertEqual(record?.isManual, true)
        XCTAssertEqual(record?.categoryOverride, "custom")
        XCTAssertEqual(result.first { $0.id == missing.id }?.availability, .missing)
    }

    func testReconciliationRelocatesOnlyUniqueIdentifierAndKeepsCopiesIndependent() {
        let old = AppRecord(url: URL(fileURLWithPath: "/old.app"), name: "Old", bundleIdentifier: "test.app", hidden: true)
        let new = DiscoveredApp(url: URL(fileURLWithPath: "/new.app"), name: "New", bundleIdentifier: "test.app")
        XCTAssertEqual(CatalogReconciler.merge(existing: [old], scan: .init(apps: [new])).first?.id, old.id)
        let copy = DiscoveredApp(url: URL(fileURLWithPath: "/copy.app"), name: "New", bundleIdentifier: "test.app")
        let ambiguous = CatalogReconciler.merge(existing: [old], scan: .init(apps: [new, copy]))
        XCTAssertEqual(ambiguous.count, 3)
        XCTAssertEqual(ambiguous.first { $0.id == old.id }?.availability, .missing)
        let oldCopy = AppRecord(url: URL(fileURLWithPath: "/old-copy.app"), name: "Old", bundleIdentifier: "test.app")
        XCTAssertEqual(CatalogReconciler.merge(existing: [old, oldCopy], scan: .init(apps: [new])).count, 3)
    }

    func testPartialScanMarksOnlyFailedRootDescendantsUnverifiedAndDoesNotRelocateThem() {
        let root = URL(fileURLWithPath: "/Applications/Vendor")
        let old = AppRecord(url: root.appendingPathComponent("Old.app"), name: "Old", bundleIdentifier: "test.app", hidden: true)
        let sibling = AppRecord(url: URL(fileURLWithPath: "/Applications/VendorElse/App.app"), name: "Sibling")
        let new = DiscoveredApp(url: URL(fileURLWithPath: "/new.app"), name: "New", bundleIdentifier: "test.app")
        let result = CatalogReconciler.merge(existing: [old, sibling], scan: .init(apps: [new], failedRoots: [root]))
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.first { $0.id == old.id }?.availability, .unverified)
        XCTAssertEqual(result.first { $0.id == sibling.id }?.availability, .missing)
    }

    func testRealBookmarksFollowMoveAndIdentityIsVolumeQualified() throws {
        let root = try fixtureRoot()
        let oldURL = try app(root, "Before.app")
        let discovered = try DiscoveryService().inspect(url: oldURL)
        let old = AppRecord(url: oldURL, name: discovered.name, bookmark: discovered.bookmark, fileIdentifier: nil, hidden: true)
        let newURL = root.appendingPathComponent("After.app")
        try FileManager.default.moveItem(at: oldURL, to: newURL)
        var fresh = try DiscoveryService().inspect(url: newURL)
        fresh.fileIdentifier = nil // Force the bookmark reconciliation path.
        let merged = CatalogReconciler.merge(existing: [old], scan: .init(apps: [fresh]))
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.first?.id, old.id)
        XCTAssertEqual(merged.first?.hidden, true)
        XCTAssertTrue(discovered.fileIdentifier?.contains(":") == true)
    }
    func testOneMissingCopyCanRelocateWhileAnotherCopyStaysInstalled() {
        let kept = AppRecord(url: URL(fileURLWithPath: "/kept.app"), name: "Kept", bundleIdentifier: "same")
        let moved = AppRecord(url: URL(fileURLWithPath: "/old.app"), name: "Old", bundleIdentifier: "same", hidden: true)
        let fresh = [DiscoveredApp(url: kept.url, name: "Kept", bundleIdentifier: "same"), DiscoveredApp(url: URL(fileURLWithPath: "/new.app"), name: "Moved", bundleIdentifier: "same")]
        let result = CatalogReconciler.merge(existing: [kept, moved], scan: .init(apps: fresh))
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first { $0.id == moved.id }?.url.path, "/new.app")
        XCTAssertEqual(result.first { $0.id == moved.id }?.hidden, true)
    }

    func testFixtureThousandAppsPerformance() throws {
        let root = try fixtureRoot()
        for index in 0..<1_000 { try app(root, "Vendor\(index / 20)/App\(index).app", id: "test.app.\(index)") }
        let start = ContinuousClock.now
        let scan = try DiscoveryService().scan(roots: [root])
        let scanDuration = start.duration(to: .now)
        XCTAssertEqual(scan.apps.count, 1_000)
        let existing = CatalogReconciler.merge(existing: [], scan: scan)
        let mergeStart = ContinuousClock.now
        let merged = CatalogReconciler.merge(existing: existing, scan: scan)
        let mergeDuration = mergeStart.duration(to: .now)
        XCTAssertEqual(Set(merged.map(\.id)), Set(existing.map(\.id)))
        print("PERFORMANCE 1000 fixture scan: \(scanDuration); warm merge: \(mergeDuration)")
    }

    func testFinderAliasesStayOutsideAutomaticTraversalButExplicitAppAliasResolves() throws {
        let root = try fixtureRoot()
        let outside = try fixtureRoot()
        let target = try app(outside, "Target.app")
        let folderAlias = root.appendingPathComponent("FolderAlias")
        let appAlias = root.appendingPathComponent("Alias.app")
        let folderBookmark = try outside.bookmarkData(options: [.suitableForBookmarkFile], includingResourceValuesForKeys: nil, relativeTo: nil)
        try URL.writeBookmarkData(folderBookmark, to: folderAlias)
        let appBookmark = try target.bookmarkData(options: [.suitableForBookmarkFile], includingResourceValuesForKeys: nil, relativeTo: nil)
        try URL.writeBookmarkData(appBookmark, to: appAlias)
        XCTAssertTrue(try appAlias.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile == true)
        XCTAssertTrue(try DiscoveryService().scan(roots: [root]).apps.isEmpty)
        let manual = try DiscoveryService().scan(roots: [root], manualURLs: [appAlias])
        XCTAssertEqual(manual.apps.count, 1)
        XCTAssertEqual(manual.apps.first?.url.path, target.path)
        XCTAssertEqual(manual.apps.first?.isManual, true)
    }

    func testDeniedNestedFolderRetainsAppsAsUnverifiedAndReadableAppsPublish() throws {
        let root = try fixtureRoot()
        let good = try app(root, "Good.app")
        let denied = try app(root, "Denied/Vendor.app")
        let folder = denied.deletingLastPathComponent()
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: folder.path)
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: folder.path) }
        let scan = try DiscoveryService().scan(roots: [root])
        XCTAssertEqual(scan.apps.map { $0.url.path }, [good.path])
        XCTAssertEqual(scan.failedRoots, [root])
        let old = AppRecord(url: denied, name: "Denied", hidden: true)
        let merged = CatalogReconciler.merge(existing: [old], scan: scan)
        XCTAssertEqual(merged.first { $0.id == old.id }?.availability, .unverified)
        XCTAssertEqual(merged.first { $0.id == old.id }?.hidden, true)
    }

    func testCancelledScanThrowsInsteadOfPublishingAnEmptyCatalog() async throws {
        let worker = Task.detached {
            withUnsafeCurrentTask { $0?.cancel() }
            return try DiscoveryService().scan(roots: [])
        }
        do {
            _ = try await worker.value
            XCTFail("Cancelled scan published a result")
        } catch is CancellationError { }
    }

    func testApplicationPassedAsRootIsStillAnOpaqueBundleBoundary() throws {
        let root = try fixtureRoot()
        let outer = try app(root, "Outer.app")
        try app(outer, "Contents/Helpers/Embedded.app")
        let scan = try DiscoveryService().scan(roots: [outer])
        XCTAssertEqual(scan.apps.map { $0.url.path }, [outer.path])
    }

}
