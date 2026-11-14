import Foundation
import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor final class VisibilityInteractionTests: XCTestCase {
    func testRestoringDefaultHiddenUninstallerPersistsThroughScanAndRestart() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let record = AppRecord(url: URL(fileURLWithPath: "/Applications/Uninstall Fixture.app"), name: "Uninstall Fixture")
        let store = PreferencesStore(directory: directory)
        try await store.save(CatalogDocument(apps: [record]))
        let scanner: CatalogModel.Scanner = { _, _, _ in ScanResult(apps: [DiscoveredApp(url: record.url, name: record.name)]) }
        let model = CatalogModel(store: store, roots: [], scanner: scanner)
        await model.start()
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while model.isScanning && ContinuousClock.now < deadline { await Task.yield() }
        XCTAssertTrue(model.visibleApps.isEmpty)
        XCTAssertTrue(model.document.apps[0].hidden)
        model.setHidden(false, id: record.id)
        XCTAssertEqual(model.visibleApps.map(\.id), [record.id])
        let saved = await model.finishSaving()
        XCTAssertTrue(saved)
        model.stop()
        let reopened = CatalogModel(store: PreferencesStore(directory: directory), roots: [], scanner: scanner)
        await reopened.start()
        let nextDeadline = ContinuousClock.now.advanced(by: .seconds(3))
        while reopened.isScanning && ContinuousClock.now < nextDeadline { await Task.yield() }
        XCTAssertEqual(reopened.visibleApps.map(\.id), [record.id])
        reopened.setHidden(true, id: record.id)
        XCTAssertTrue(reopened.launcherApps(category: nil, query: "").isEmpty)
        reopened.stop()
        _ = await reopened.finishSaving()
    }
}
