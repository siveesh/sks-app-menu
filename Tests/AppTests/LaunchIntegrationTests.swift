import AppKit
import Foundation
import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor final class LaunchIntegrationTests: XCTestCase {
    func testManualAppLaunchesExactSelectedURL() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let bundle = directory.appendingPathComponent("Controlled.app")
        let macOS = bundle.appendingPathComponent("Contents/MacOS")
        try FileManager.default.createDirectory(at: macOS, withIntermediateDirectories: true)
        let info: [String: Any] = ["CFBundlePackageType":"APPL", "CFBundleExecutable":"Controlled", "CFBundleIdentifier":"com.siveesh.sksappmenu.controlled", "CFBundleName":"Controlled", "NSPrincipalClass":"NSApplication"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: bundle.appendingPathComponent("Contents/Info.plist"))
        let source = directory.appendingPathComponent("fixture.swift")
        try """
        import AppKit
        final class Delegate: NSObject, NSApplicationDelegate {
            func applicationDidFinishLaunching(_ notification: Notification) {
                let url = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("launched.txt")
                try? Data(Bundle.main.bundleURL.path.utf8).write(to: url)
                NSApp.terminate(nil)
            }
        }
        let app = NSApplication.shared
        let delegate = Delegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
        """.write(to: source, atomically: true, encoding: .utf8)
        let compiler = Process()
        compiler.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        compiler.arguments = ["swiftc", source.path, "-o", macOS.appendingPathComponent("Controlled").path]
        try compiler.run(); compiler.waitUntilExit()
        XCTAssertEqual(compiler.terminationStatus, 0)
        let store = PreferencesStore(directory: directory.appendingPathComponent("Settings"))
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        await model.start()
        await model.addApplication(at: bundle)
        let record = try XCTUnwrap(model.document.apps.first)
        XCTAssertTrue(record.isManual)
        model.launch(record)
        let proof = directory.appendingPathComponent("launched.txt")
        for _ in 0..<120 {
            if FileManager.default.fileExists(atPath: proof.path) { break }
            try await Task.sleep(for: .milliseconds(50))
        }
        XCTAssertEqual(URL(fileURLWithPath: try String(contentsOf: proof, encoding: .utf8)).resolvingSymlinksInPath().path, bundle.resolvingSymlinksInPath().path)
        XCTAssertNil(model.operationError)
        _ = await model.finishSaving()
        model.stop()
    }
}
