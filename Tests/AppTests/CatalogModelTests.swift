import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor
final class CatalogModelTests: XCTestCase {
    func testFailedLoadMakesEditsReadOnlyAndNeverSavesDefaults() async {
        let persistence = MemoryCatalogStore(failLoad: true)
        let model = CatalogModel(store: persistence, roots: [], scanner: emptyScan)
        await model.start()
        model.createCategory(named: "Personal")
        await Task.yield()
        XCTAssertTrue(model.isReadOnly)
        XCTAssertTrue(model.document.categories.isEmpty)
        let count = await persistence.saveCount
        XCTAssertEqual(count, 0)
    }

    func testNewestEditAndFinishSavingWaitForSuspendedSave() async {
        let persistence = ControlledCatalogStore()
        let model = CatalogModel(store: persistence, roots: [], scanner: emptyScan)
        await model.start()
        model.stop()
        model.createCategory(named: "First")
        await persistence.waitForSave()
        model.createCategory(named: "Second")
        XCTAssertTrue(model.hasUnsavedChanges)
        let finishing = Task { await model.finishSaving() }
        await persistence.releaseSave()
        let savedSuccessfully = await finishing.value
        XCTAssertTrue(savedSuccessfully)
        let saved = await persistence.document
        XCTAssertEqual(Set(saved.categories.map(\.name)), ["First", "Second"])
        XCTAssertFalse(model.hasUnsavedChanges)
        XCTAssertNil(model.saveWarning)
    }

    func testScanPublicationPreservesEditsMadeWhileWorkerIsBlocked() async {
        let app = AppRecord(url: URL(fileURLWithPath: "/Applications/Test.app"), name: "Test")
        let persistence = MemoryCatalogStore(document: CatalogDocument(apps: [app]))
        let gate = ScanGate()
        let model = CatalogModel(store: persistence, roots: [], scanner: { _, _, _ in
            gate.wait()
            return ScanResult(apps: [DiscoveredApp(url: app.url, name: "Updated Test")])
        })
        await model.start()
        await gate.waitUntilStarted()
        model.setHidden(true, id: app.id)
        model.createCategory(named: "Personal")
        let category = model.document.categories[0].id
        model.setCategory(category, id: app.id)
        model.refresh()
        model.refresh()
        gate.release()
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while model.isScanning && ContinuousClock.now < deadline { await Task.yield() }
        XCTAssertFalse(model.isScanning)
        XCTAssertEqual(model.document.apps.first?.name, "Updated Test")
        XCTAssertEqual(model.document.apps.first?.hidden, true)
        XCTAssertEqual(model.document.apps.first?.categoryOverride, category)
        XCTAssertEqual(gate.callCount, 2, "Repeated requests should coalesce into one follow-up scan")
        _ = await model.finishSaving()
    }

    func testStoppedScanMustExitBeforeRestartBegins() async throws {
        let gate = ScanGate()
        let model = CatalogModel(store: MemoryCatalogStore(), roots: [], scanner: { _, _, _ in gate.wait(); return ScanResult() })
        await model.start()
        await gate.waitUntilStarted()
        model.stop()
        model.refresh()
        try await Task.sleep(for: .milliseconds(40))
        XCTAssertEqual(gate.callCount, 1, "Cancellation must not permit overlapping workers")
        gate.release()
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while (model.isScanning || gate.callCount < 2) && ContinuousClock.now < deadline { await Task.yield() }
        XCTAssertEqual(gate.callCount, 2)
        _ = await model.finishSaving()
    }

    func testManualAddIsNotLostWhenOlderScanCompletes() async throws {
        let url = try makeFixture()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let gate = ScanGate()
        let model = CatalogModel(store: MemoryCatalogStore(), roots: [], scanner: { _, manual, _ in
            gate.wait()
            return ScanResult(apps: try manual.map { try DiscoveryService().inspect(url: $0, allowBackground: true) })
        })
        await model.start()
        await gate.waitUntilStarted()
        await model.addApplication(at: url)
        gate.release()
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while model.isScanning && ContinuousClock.now < deadline { await Task.yield() }
        XCTAssertEqual(model.document.apps.count, 1)
        XCTAssertEqual(model.document.apps.first?.availability, .available)
        _ = await model.finishSaving()
    }

    func testLocateExistingDiscoveredCopyRetainsMissingIdentityAndPreferences() async throws {
        let url = try makeFixture()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let category = AppCategory(name: "Personal")
        let missing = AppRecord(url: URL(fileURLWithPath: "/old/Test.app"), name: "Test", hidden: true, categoryOverride: category.id, availability: .missing)
        let discovered = AppRecord(url: url, name: "Test")
        let persistence = MemoryCatalogStore(document: CatalogDocument(apps: [missing, discovered], categories: [category]))
        let gate = ScanGate()
        let model = CatalogModel(store: persistence, roots: [], scanner: { _, _, _ in gate.wait(); return ScanResult() })
        await model.start()
        await gate.waitUntilStarted()
        await model.addApplication(at: url, replacing: missing.id)
        XCTAssertEqual(model.document.apps.count, 1)
        XCTAssertEqual(model.document.apps.first?.id, missing.id)
        XCTAssertEqual(model.document.apps.first?.url.standardizedFileURL.path, url.standardizedFileURL.path)
        XCTAssertEqual(model.document.apps.first?.hidden, true)
        XCTAssertEqual(model.document.apps.first?.categoryOverride, category.id)
        model.stop()
        gate.release()
        _ = await model.finishSaving()
    }

    private func makeFixture() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let app = root.appendingPathComponent("Test.app")
        let contents = app.appendingPathComponent("Contents")
        let macOS = contents.appendingPathComponent("MacOS")
        try FileManager.default.createDirectory(at: macOS, withIntermediateDirectories: true)
        let info: [String: String] = ["CFBundlePackageType": "APPL", "CFBundleExecutable": "Test", "CFBundleName": "Test", "CFBundleIdentifier": "com.test.fixture"]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: contents.appendingPathComponent("Info.plist"))
        let executable = macOS.appendingPathComponent("Test")
        try Data("#!/bin/sh\nexit 0\n".utf8).write(to: executable)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: executable.path)
        return app
    }

    func testSaveRecoveryFailureDisablesEditsAndOffersRecovery() async {
        let persistence = MemoryCatalogStore(failSave: true)
        let model = CatalogModel(store: persistence, roots: [], scanner: emptyScan)
        await model.start()
        model.createCategory(named: "Personal")
        _ = await model.finishSaving()
        XCTAssertTrue(model.isReadOnly)
        XCTAssertNotNil(model.recoveryWarning)
        XCTAssertNotNil(model.saveWarning)
        model.createCategory(named: "Blocked")
        XCTAssertFalse(model.document.categories.contains { $0.name == "Blocked" })
    }

    func testCategoryValidationAndDeletionResetsAssignments() async {
        let category = AppCategory(id: UUID().uuidString, name: "Personal", isBuiltIn: false)
        let app = AppRecord(url: URL(fileURLWithPath: "/Applications/Test.app"), name: "Test", categoryOverride: category.id)
        let persistence = MemoryCatalogStore(document: CatalogDocument(apps: [app], categories: [category]))
        let model = CatalogModel(store: persistence, roots: [], scanner: emptyScan)
        await model.start()
        model.createCategory(named: " personal ")
        XCTAssertEqual(model.document.categories.count, 1)
        model.deleteCategory(id: category.id)
        XCTAssertTrue(model.document.categories.isEmpty)
        XCTAssertNil(model.document.apps.first?.categoryOverride)
    }
}

private let emptyScan: CatalogModel.Scanner = { _, _, _ in ScanResult(apps: [], failedRoots: [], warnings: []) }

private actor MemoryCatalogStore: CatalogPersistence {
    var document: CatalogDocument
    let failLoad: Bool
    let failSave: Bool
    var saveCount = 0
    init(document: CatalogDocument = CatalogDocument(), failLoad: Bool = false, failSave: Bool = false) {
        self.document = document
        self.failLoad = failLoad
        self.failSave = failSave
    }
    func load() throws -> CatalogDocument {
        if failLoad { throw CocoaError(.fileReadCorruptFile) }
        return document
    }
    func save(_ value: CatalogDocument) async throws {
        if failSave { throw PreferencesError.recoveryRequired }
        await Task.yield()
        document = value
        saveCount += 1
    }
    func restoreBackup() throws { }
    func archiveAndReset() throws { document = CatalogDocument() }
}

private actor ControlledCatalogStore: CatalogPersistence {
    var document = CatalogDocument()
    private var release: CheckedContinuation<Void, Never>?
    private var started: CheckedContinuation<Void, Never>?
    private var hasStarted = false
    func load() -> CatalogDocument { document }
    func save(_ value: CatalogDocument) async {
        if !hasStarted {
            hasStarted = true
            started?.resume()
            started = nil
            await withCheckedContinuation { release = $0 }
        }
        document = value
    }
    func waitForSave() async {
        if hasStarted { return }
        await withCheckedContinuation { started = $0 }
    }
    func releaseSave() { release?.resume(); release = nil }
    func restoreBackup() { }
    func archiveAndReset() { document = CatalogDocument() }
}

/// A deliberately suspended synchronous scanner, representing blocking filesystem work.
private final class ScanGate: @unchecked Sendable {
    private let condition = NSCondition()
    private var released = false
    private var started = false
    private var calls = 0
    var callCount: Int { condition.lock(); defer { condition.unlock() }; return calls }
    func wait() {
        condition.lock()
        calls += 1
        started = true
        condition.broadcast()
        while !released { condition.wait() }
        condition.unlock()
    }
    func waitUntilStarted() async {
        await Task.detached { [self] in waitForStart() }.value
    }
    private func waitForStart() {
        condition.lock()
        while !started { condition.wait() }
        condition.unlock()
    }
    func release() { condition.lock(); released = true; condition.broadcast(); condition.unlock() }
}
