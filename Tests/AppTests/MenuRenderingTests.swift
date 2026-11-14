import AppKit
import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor final class MenuRenderingTests: XCTestCase {
    func testHidingRefreshWarningsKeepsDiagnosticsAndSurvivesRestartUntilReenabled() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = PreferencesStore(directory: directory)
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult(warnings: ["Unreadable fixture"]) })
        await model.start()
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while model.isScanning && ContinuousClock.now < deadline { await Task.yield() }
        let controller = MenuController(model: model, windows: WindowActionRelay(activate: {}))
        XCTAssertNotNil(controller.menu.item(withTitle: "Refresh Warnings…"))
        let toggle = try XCTUnwrap(controller.menu.item(withTitle: "Hide Refresh Warnings"))
        XCTAssertEqual(toggle.state, .off)
        NSApp.sendAction(try XCTUnwrap(toggle.action), to: toggle.target, from: toggle)
        XCTAssertNil(controller.menu.item(withTitle: "Refresh Warnings…"))
        XCTAssertEqual(model.scanWarnings, ["Unreadable fixture"], "Hidden diagnostics remain inspectable in management")
        XCTAssertEqual(controller.menu.item(withTitle: "Hide Refresh Warnings")?.state, .on)
        let saved = await model.finishSaving()
        XCTAssertTrue(saved)
        model.stop()

        let reopened = CatalogModel(store: PreferencesStore(directory: directory), roots: [], scanner: { _, _, _ in ScanResult(warnings: ["Unreadable fixture"]) })
        await reopened.start()
        let nextDeadline = ContinuousClock.now.advanced(by: .seconds(3))
        while reopened.isScanning && ContinuousClock.now < nextDeadline { await Task.yield() }
        let nextMenu = MenuController(model: reopened, windows: WindowActionRelay(activate: {}))
        XCTAssertNil(nextMenu.menu.item(withTitle: "Refresh Warnings…"))
        let restore = try XCTUnwrap(nextMenu.menu.item(withTitle: "Hide Refresh Warnings"))
        XCTAssertEqual(restore.state, .on)
        NSApp.sendAction(try XCTUnwrap(restore.action), to: restore.target, from: restore)
        XCTAssertNotNil(nextMenu.menu.item(withTitle: "Refresh Warnings…"))
        reopened.stop()
        _ = await reopened.finishSaving()
    }

    func testApplicationMenuKeepsRealIconsVisibleOnMacOS27() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let app = AppRecord(url: URL(fileURLWithPath: "/System/Applications/TextEdit.app"), name: "TextEdit", automaticCategory: "productivity")
        let store = PreferencesStore(directory: directory)
        try await store.save(CatalogDocument(apps: [app]))
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in
            ScanResult(apps: [DiscoveredApp(url: app.url, name: app.name, automaticCategory: app.automaticCategory)])
        })
        await model.start()
        let controller = MenuController(model: model, windows: WindowActionRelay())
        let row = try XCTUnwrap(controller.menu.items.compactMap(\.submenu).flatMap(\.items).first { $0.representedObject as? UUID == app.id })
        XCTAssertNotNil(row.image)
        XCTAssertEqual(row.image?.size, NSSize(width: 16, height: 16))
        XCTAssertEqual(row.preferredImageVisibility, .visible, "Automatic visibility hides app icons under macOS 27's menu policy")
        model.stop()
        _ = await model.finishSaving()
    }
}
