import AppKit
import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor final class MenuRenderingTests: XCTestCase {
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
