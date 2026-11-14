import Foundation
import XCTest
@testable import MenuCore

final class IOSDiscoveryTests: XCTestCase, @unchecked Sendable {
    private func root() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }
    private func payload(_ url: URL, ios: Bool = true) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        var info: [String: Any] = ["CFBundlePackageType":"APPL", "CFBundleExecutable":"Fixture", "CFBundleIdentifier":"test.ios", "CFBundleDisplayName":"Mobile App", "LSApplicationCategoryType":"public.app-category.video"]
        if ios { info["LSRequiresIPhoneOS"] = true; info["CFBundleSupportedPlatforms"] = ["iPhoneOS"] }
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: url.appendingPathComponent("Info.plist"))
        try Data("#!/bin/sh\nexit 0\n".utf8).write(to: url.appendingPathComponent("Fixture"))
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.appendingPathComponent("Fixture").path)
    }
    func testWrappedIOSAppUsesPayloadMetadataButOuterLaunchURL() throws {
        let root = try root()
        let outer = root.appendingPathComponent("Mobile.app")
        let inner = outer.appendingPathComponent("Wrapper/Runner.app")
        try payload(inner)
        try FileManager.default.createSymbolicLink(atPath: outer.appendingPathComponent("WrappedBundle").path, withDestinationPath: "Wrapper/Runner.app")
        let result = try DiscoveryService().scan(roots: [root], manualURLs: [outer])
        XCTAssertEqual(result.apps.count, 1)
        XCTAssertTrue(result.warnings.isEmpty)
        let app = try XCTUnwrap(result.apps.first)
        XCTAssertEqual(app.url.path, outer.path)
        XCTAssertEqual(app.name, "Mobile App")
        XCTAssertEqual(app.bundleIdentifier, "test.ios")
        XCTAssertEqual(app.automaticCategory, "ios-apps")
        XCTAssertTrue(app.isManual)
        XCTAssertEqual(CategoryResolver.name(for: "ios-apps"), "iOS Apps")
    }
    func testFlatIOSAndSinglePayloadWrapperWithoutLinkAreSupported() throws {
        let root = try root()
        let flat = root.appendingPathComponent("Flat.app")
        let outer = root.appendingPathComponent("Wrapped.app")
        try payload(flat)
        try payload(outer.appendingPathComponent("Wrapper/Internal.app"))
        let result = try DiscoveryService().scan(roots: [root])
        XCTAssertEqual(Set(result.apps.map { $0.url.path }), [flat.path,outer.path])
        XCTAssertTrue(result.apps.allSatisfy { $0.automaticCategory == "ios-apps" })
        XCTAssertTrue(result.warnings.isEmpty)
    }
    func testInvalidWrapperAndEscapingPayloadStillWarnInsteadOfBeingClassifiedIOS() throws {
        let root = try root()
        let outside = try self.root()
        let external = outside.appendingPathComponent("External.app")
        try payload(external)
        let escape = root.appendingPathComponent("Escape.app")
        try FileManager.default.createDirectory(at: escape, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(at: escape.appendingPathComponent("WrappedBundle"), withDestinationURL: external)
        try payload(root.appendingPathComponent("NotIOS.app/Wrapper/Fake.app"), ios: false)
        let unreadable = root.appendingPathComponent("Unreadable.app/Wrapper/Hidden.app")
        try payload(unreadable)
        let plist = unreadable.appendingPathComponent("Info.plist")
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: plist.path)
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: plist.path) }
        let result = try DiscoveryService().scan(roots: [root])
        XCTAssertTrue(result.apps.isEmpty)
        XCTAssertEqual(result.warnings.filter { $0.hasPrefix("Skipped invalid or inaccessible application") }.count, 3)
        XCTAssertEqual(result.failedRoots.map(\.path), [root.path])
    }
    func testExistingCustomIOSAppsCategoryRemainsReadableAfterUpgrade() async throws {
        let root = try root()
        let legacy = AppCategory(id: "legacy-custom", name: "iOS Apps")
        let app = AppRecord(url: root.appendingPathComponent("Existing.app"), name: "Existing", hidden: true, categoryOverride: legacy.id)
        let document = CatalogDocument(apps: [app], categories: [legacy])
        try JSONEncoder().encode(document).write(to: root.appendingPathComponent("catalog.json"))
        let loaded = try await PreferencesStore(directory: root).load()
        XCTAssertEqual(loaded, document)
    }

    func testIOSReconciliationRetainsVisibilityAndCategoryOverride() {
        let url = URL(fileURLWithPath: "/Applications/Mobile.app")
        let old = AppRecord(url: url, name: "Old", hidden: true, categoryOverride: "video")
        let scan = ScanResult(apps: [DiscoveredApp(url: url, name: "Mobile App", automaticCategory: "ios-apps")])
        let merged = CatalogReconciler.merge(existing: [old], scan: scan)
        XCTAssertEqual(merged.first?.id, old.id)
        XCTAssertTrue(merged.first?.hidden == true)
        XCTAssertEqual(merged.first?.automaticCategory, "ios-apps")
        XCTAssertEqual(merged.first?.categoryOverride, "video")
    }
}
