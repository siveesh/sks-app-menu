import AppKit
import XCTest
import MenuCore
@testable import SKsAppMenu

@MainActor
final class DockLauncherTests: XCTestCase {
    func testEarlyOpenIsQueuedAndRepeatedRequestsCoalesce() {
        let relay = WindowActionRelay()
        relay.open("launcher")
        relay.open("launcher")
        var opened: [String] = []
        relay.openWindow = { opened.append($0) }
        XCTAssertEqual(opened, ["launcher"], "A Dock click before SwiftUI registers its scene action must be delivered once")
    }
}

@MainActor
final class DockLifecycleTests: XCTestCase {
    func testMenuLaunchFailureRestoresMinimizedLauncherForRecovery() async {
        let model = CatalogModel(store: DockTestStore(), roots: [], scanner: { _, _, _ in ScanResult() })
        await model.start()
        model.stop()
        _ = await model.finishSaving()
        let window = MinimizedLauncherFixtureWindow(contentRect: NSRect(x: 100, y: 100, width: 520, height: 360),
                              styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.close() }
        var restored: [String] = []
        var opened: [String] = []
        let relay = WindowActionRelay(activate: {}, restoreWindow: { id in restored.append(id); return true })
        relay.registerLauncher(window)
        relay.openWindow = { opened.append($0) }
        let menu = MenuController(model: model, windows: relay)
        let absent = AppRecord(url: URL(fileURLWithPath: "/nonexistent/\(UUID().uuidString).app"), name: "Unavailable fixture")
        model.launch(absent)
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while model.operationError == nil && ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertNotNil(model.operationError)
        XCTAssertEqual(restored, ["launcher"], "A menu launch failure must raise the minimized error surface")
        XCTAssertTrue(opened.isEmpty, "The existing launcher provides recovery without a duplicate scene")
        withExtendedLifetime(menu) { }
    }

    func testFailedPolicyChangeKeepsSavedAndEffectivePreference() async {
        let store = DockTestStore()
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        let relay = WindowActionRelay(activate: {})
        var opened: [String] = []
        relay.openWindow = { opened.append($0) }
        let controller = DockPresenceController(model: model, windows: relay, setPolicy: { _ in false })
        await model.start()
        model.setShowInDock(true)
        XCTAssertFalse(model.document.presentation.showInDock)
        XCTAssertFalse(model.effectiveShowInDock)
        XCTAssertNotNil(model.dockWarning)
        XCTAssertTrue(opened.isEmpty)
        XCTAssertFalse(controller.isEnabled)
        model.stop()
        _ = await model.finishSaving()
    }

    func testStartupActivationFailurePreservesLoadedPreferenceAndShowsEffectiveOff() async {
        let store = DockTestStore(document: CatalogDocument(presentation: PresentationPreferences(showInDock: true, launcherDensity: .compact)))
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        let controller = DockPresenceController(model: model, windows: WindowActionRelay(activate: {}), setPolicy: { _ in false })
        await model.start()
        XCTAssertTrue(model.document.presentation.showInDock)
        XCTAssertFalse(model.effectiveShowInDock)
        XCTAssertFalse(controller.isEnabled)
        XCTAssertNotNil(model.dockWarning)
        XCTAssertEqual(model.document.presentation.launcherDensity, .compact)
        model.stop()
        _ = await model.finishSaving()
    }

    func testRecoveryReappliesBackupPresentationThroughPolicyBoundary() async {
        let store = DockTestStore(failSave: true)
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        var policies: [NSApplication.ActivationPolicy] = []
        let controller = DockPresenceController(model: model, windows: WindowActionRelay(activate: {}), setPolicy: { policies.append($0); return true })
        await model.start()
        model.stop()
        model.setShowInDock(true)
        model.setLauncherDensity(.spacious)
        _ = await model.finishSaving()
        XCTAssertTrue(model.isReadOnly)
        await model.recoverBackup()
        model.stop()
        XCTAssertEqual(model.document.presentation, PresentationPreferences())
        XCTAssertFalse(controller.isEnabled)
        XCTAssertFalse(model.effectiveShowInDock)
        XCTAssertEqual(policies, [.regular, .accessory])
        _ = await model.finishSaving()
    }

    func testEnableDisableAndReopenAlwaysRouteOnlyLauncher() async {
        let model = CatalogModel(store: DockTestStore(), roots: [], scanner: { _, _, _ in ScanResult() })
        let relay = WindowActionRelay(activate: {})
        var opened: [String] = []
        var closed: [String] = []
        var policies: [NSApplication.ActivationPolicy] = []
        relay.openWindow = { opened.append($0) }
        relay.closeWindow = { closed.append($0) }
        let controller = DockPresenceController(model: model, windows: relay, setPolicy: { policies.append($0); return true })
        await model.start()
        XCTAssertTrue(opened.isEmpty)
        model.setShowInDock(true)
        controller.reopen()
        XCTAssertEqual(opened, ["launcher", "launcher"])
        XCTAssertEqual(policies, [.regular])
        model.setShowInDock(false)
        XCTAssertEqual(closed, ["launcher"])
        controller.reopen()
        XCTAssertEqual(opened.count, 2)
        XCTAssertEqual(policies, [.regular, .accessory])
        model.stop()
        _ = await model.finishSaving()
    }

    func testSavedDockStartupQueuesLauncherAndDisableCancelsPendingOpen() async {
        let store = DockTestStore(document: CatalogDocument(presentation: PresentationPreferences(showInDock: true)))
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        let relay = WindowActionRelay(activate: {})
        let controller = DockPresenceController(model: model, windows: relay, setPolicy: { _ in true })
        controller.reopen() // Early Dock event must wait for the loaded preference.
        await model.start()
        var opened: [String] = []
        relay.openWindow = { opened.append($0) }
        XCTAssertEqual(opened, ["launcher"])
        relay.openWindow = nil
        controller.reopen()
        model.setShowInDock(false)
        relay.openWindow = { opened.append($0) }
        XCTAssertEqual(opened, ["launcher"])
        model.stop()
        _ = await model.finishSaving()
    }

    func testExistingMinimizedLauncherUsesRestoreBridgeWithoutOpeningAnotherScene() {
        var restored = 0
        var opened: [String] = []
        let relay = WindowActionRelay(activate: {}, restoreWindow: { id in
            guard id == "launcher" else { return false }
            restored += 1
            return true
        })
        relay.openWindow = { opened.append($0) }
        relay.open("launcher")
        XCTAssertEqual(restored, 1)
        XCTAssertTrue(opened.isEmpty)
    }

    func testDensityChangesSurviveSuspendedSaveAndScanPublication() async {
        let gate = DockScanGate()
        let store = DockTestStore(suspendFirstSave: true)
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in gate.wait(); return ScanResult() })
        let controller = DockPresenceController(model: model, windows: WindowActionRelay(activate: {}), setPolicy: { _ in true })
        await model.start()
        await gate.waitUntilStarted()
        model.setLauncherDensity(.compact)
        await store.waitForSave()
        model.setLauncherDensity(.spacious)
        model.setShowInDock(true)
        gate.release()
        while model.isScanning { await Task.yield() }
        await store.releaseSave()
        let saved = await model.finishSaving()
        XCTAssertTrue(saved)
        let document = await store.document
        XCTAssertEqual(document.presentation.launcherDensity, .spacious)
        XCTAssertTrue(document.presentation.showInDock)
        XCTAssertTrue(controller.isEnabled)
        model.stop()
    }

    func testFailedDisableRetainsEnabledSavedStateAndLauncher() async {
        let model = CatalogModel(store: DockTestStore(), roots: [], scanner: { _, _, _ in ScanResult() })
        let windows = WindowActionRelay(activate: {})
        windows.openWindow = { _ in }
        var closed = false
        windows.closeWindow = { _ in closed = true }
        let controller = DockPresenceController(model: model, windows: windows, setPolicy: { $0 == .regular })
        await model.start()
        model.setShowInDock(true)
        model.setShowInDock(false)
        XCTAssertTrue(controller.isEnabled)
        XCTAssertTrue(model.effectiveShowInDock)
        XCTAssertTrue(model.document.presentation.showInDock)
        XCTAssertFalse(closed)
        XCTAssertNotNil(model.dockWarning)
        model.stop()
        _ = await model.finishSaving()
    }

    func testLauncherFilteringUsesVisibleCatalogAndSelectedCategory() async {
        let visible = AppRecord(url: URL(fileURLWithPath: "/Applications/One.app"), name: "One", automaticCategory: "productivity")
        let hidden = AppRecord(url: URL(fileURLWithPath: "/Applications/Hidden.app"), name: "Hidden", hidden: true)
        let missing = AppRecord(url: URL(fileURLWithPath: "/Applications/Missing.app"), name: "Missing", availability: .missing)
        let other = AppRecord(url: URL(fileURLWithPath: "/Other/Two.app"), name: "Two", automaticCategory: "utilities", availability: .unverified)
        let model = CatalogModel(store: DockTestStore(document: CatalogDocument(apps: [visible, hidden, missing, other])), roots: [], scanner: { _, _, _ in ScanResult() })
        await model.start()
        model.stop()
        XCTAssertEqual(Set(model.launcherApps(category: nil, query: "").map(\.id)), [visible.id, other.id])
        XCTAssertEqual(model.launcherApps(category: model.categoryName(for: visible), query: "applications").map(\.id), [visible.id])
        XCTAssertEqual(model.launcherApps(category: nil, query: "other").map(\.id), [other.id])
        XCTAssertTrue(model.launcherApps(category: model.categoryName(for: visible), query: "Two").isEmpty)
    }

    func testReadOnlyCatalogRejectsPresentationEditsWithoutChangingPolicy() async {
        let store = DockTestStore(failLoad: true)
        let model = CatalogModel(store: store, roots: [], scanner: { _, _, _ in ScanResult() })
        var policies = 0
        let controller = DockPresenceController(model: model, windows: WindowActionRelay(activate: {}), setPolicy: { _ in policies += 1; return true })
        await model.start()
        model.setShowInDock(true)
        model.setLauncherDensity(.spacious)
        XCTAssertEqual(policies, 0)
        XCTAssertFalse(controller.isEnabled)
        XCTAssertEqual(model.document.presentation, PresentationPreferences())
        let count = await store.saveCount
        XCTAssertEqual(count, 0)
    }
}

private actor DockTestStore: CatalogPersistence {
    var document: CatalogDocument
    let failLoad: Bool
    let suspendFirstSave: Bool
    private var failSave: Bool
    private var saveStarted = false
    private var waitingForStart: CheckedContinuation<Void, Never>?
    private var resumeSave: CheckedContinuation<Void, Never>?
    var saveCount = 0
    init(document: CatalogDocument = CatalogDocument(), failLoad: Bool = false, suspendFirstSave: Bool = false, failSave: Bool = false) {
        self.document = document
        self.failLoad = failLoad
        self.suspendFirstSave = suspendFirstSave
        self.failSave = failSave
    }
    func load() throws -> CatalogDocument {
        if failLoad { throw CocoaError(.fileReadCorruptFile) }
        return document
    }
    func save(_ value: CatalogDocument) async throws {
        if failSave { throw PreferencesError.recoveryRequired }
        if suspendFirstSave && !saveStarted {
            saveStarted = true
            waitingForStart?.resume(); waitingForStart = nil
            await withCheckedContinuation { resumeSave = $0 }
        }
        document = value
        saveCount += 1
    }
    func waitForSave() async {
        if saveStarted { return }
        await withCheckedContinuation { waitingForStart = $0 }
    }
    func releaseSave() { resumeSave?.resume(); resumeSave = nil }
    func restoreBackup() { document = CatalogDocument(); failSave = false }
    func archiveAndReset() { document = CatalogDocument() }
}

private final class DockScanGate: @unchecked Sendable {
    private let condition = NSCondition()
    private var started = false
    private var released = false
    func wait() {
        condition.lock()
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

/// Hosted accessory test apps cannot reliably ask the Dock to animate a real miniaturization.
/// Supply only that external window state; error publication and routing remain production code.
@MainActor private final class MinimizedLauncherFixtureWindow: NSWindow {
    override var isMiniaturized: Bool { true }
    override var isVisible: Bool { false }
}
