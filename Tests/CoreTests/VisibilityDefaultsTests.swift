import Foundation
import XCTest
@testable import MenuCore

final class VisibilityDefaultsTests: XCTestCase {
    func testUninstallNamesDefaultHiddenWithoutFilteringOrdinaryNamesOrLocations() {
        for name in ["Uninstall Resolve", "Creative Cloud Uninstaller", "UNINSTALL Tool", "preUninstallHelper"] {
            XCTAssertTrue(AppRecord(url: URL(fileURLWithPath: "/Applications/Test.app"), name: name).hidden, name)
        }
        XCTAssertFalse(AppRecord(url: URL(fileURLWithPath: "/Applications/Uninstall Tools/Editor.app"), name: "Editor").hidden)
        XCTAssertFalse(AppRecord(url: URL(fileURLWithPath: "/Applications/Uninstall.app"), name: "Uninstall", hidden: false).hidden, "Explicit restore wins over the name default")
    }

    func testLegacyVisibleUninstallersAdoptDefaultWhileExistingHiddenChoiceIsPreserved() throws {
        let data = Data(#"{"id":"1D9D75F8-CA5A-4C91-9985-88099A4FDE6D","url":"file:///Applications/Uninstall.app","name":"Uninstall Legacy","version":"1","automaticCategory":"other","isManual":false,"hidden":false,"availability":"available"}"#.utf8)
        let decoded = try JSONDecoder().decode(AppRecord.self, from: data)
        XCTAssertTrue(decoded.hidden)
        let automaticRoundTrip = try JSONDecoder().decode(AppRecord.self, from: JSONEncoder().encode(decoded))
        let normalScan = ScanResult(apps: [DiscoveredApp(url: decoded.url, name: "Editor")])
        XCTAssertFalse(CatalogReconciler.merge(existing: [automaticRoundTrip], scan: normalScan)[0].hidden)
        let oldHiddenData = Data(String(decoding: data, as: UTF8.self).replacingOccurrences(of: "\"hidden\":false", with: "\"hidden\":true").utf8)
        let oldHidden = try JSONDecoder().decode(AppRecord.self, from: oldHiddenData)
        XCTAssertTrue(CatalogReconciler.merge(existing: [oldHidden], scan: normalScan)[0].hidden)
    }

    func testAutomaticVisibilityFollowsRenamesButExplicitChoiceWins() {
        let url = URL(fileURLWithPath: "/Applications/Tool.app")
        let ordinary = AppRecord(url: url, name: "Tool")
        let uninstall = CatalogReconciler.merge(existing: [ordinary], scan: ScanResult(apps: [DiscoveredApp(url: url, name: "Uninstall Tool")]))
        XCTAssertTrue(uninstall[0].hidden)
        let renamed = CatalogReconciler.merge(existing: uninstall, scan: ScanResult(apps: [DiscoveredApp(url: url, name: "Tool")]))
        XCTAssertFalse(renamed[0].hidden)
        let restored = AppRecord(url: url, name: "Uninstall Tool", hidden: false)
        XCTAssertFalse(CatalogReconciler.merge(existing: [restored], scan: ScanResult(apps: [DiscoveredApp(url: url, name: "Uninstall New Tool")]))[0].hidden)
        let userHidden = AppRecord(url: url, name: "Tool", hidden: true)
        XCTAssertTrue(CatalogReconciler.merge(existing: [userHidden], scan: ScanResult(apps: [DiscoveredApp(url: url, name: "Other")]))[0].hidden)
    }

    func testMalformedVisibilityOwnershipCannotBeSilentlyAccepted() throws {
        let data = Data(#"{"id":"1D9D75F8-CA5A-4C91-9985-88099A4FDE6D","url":"file:///Applications/Tool.app","name":"Tool","version":"1","automaticCategory":"other","isManual":false,"hidden":false,"visibilityIsUserSet":"yes","availability":"available"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(AppRecord.self, from: data))
    }
}
