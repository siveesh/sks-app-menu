import AppKit
import Foundation
import MenuCore
import Observation
import UniformTypeIdentifiers

protocol CatalogPersistence: Sendable {
    func load() async throws -> CatalogDocument
    func save(_ document: CatalogDocument) async throws
    func restoreBackup() async throws
    func archiveAndReset() async throws
}

extension PreferencesStore: CatalogPersistence { }

/// Owns user edits on MainActor. Slow scanning and storage never own the UI snapshot.
@MainActor @Observable
final class CatalogModel {
    typealias Scanner = @Sendable ([URL], [URL], URL?) throws -> ScanResult
    private(set) var document = CatalogDocument()
    private(set) var isLoading = true
    private(set) var isReadOnly = false
    private(set) var isScanning = false
    private(set) var recoveryWarning: String?
    private(set) var saveWarning: String?
    private(set) var scanWarnings: [String] = []
    var operationError: String?
    var selectedAppID: UUID?
    private(set) var relocationConfirmation: String?
    @ObservationIgnored private var pendingRelocation: (app: DiscoveredApp, requestedID: UUID, duplicateID: UUID)?
    @ObservationIgnored var didChange: (() -> Void)?
    @ObservationIgnored private let store: any CatalogPersistence
    @ObservationIgnored private let scanner: Scanner
    @ObservationIgnored private let roots: [URL]
    @ObservationIgnored private var scanTask: Task<ScanResult, Error>?
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private var scanGeneration = UUID()
    @ObservationIgnored private var refreshPending = false
    @ObservationIgnored private var discardCurrentScan = false
    @ObservationIgnored private var revision: UInt64 = 0
    @ObservationIgnored private var savedRevision: UInt64 = 0
    @ObservationIgnored private var started = false

    init(store: any CatalogPersistence, roots: [URL] = CatalogModel.defaultRoots,
         scanner: @escaping Scanner = { roots, manual, excluded in
             try DiscoveryService().scan(roots: roots, manualURLs: manual, excluding: excluded)
         }) {
        self.store = store
        self.roots = roots
        self.scanner = scanner
    }

    static var defaultRoots: [URL] {
        [URL(fileURLWithPath: "/Applications"), URL(fileURLWithPath: "/System/Applications"),
         FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications")]
    }

    var categories: [AppCategory] {
        (CategoryResolver.builtIn + document.categories).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var canEdit: Bool { !isLoading && !isReadOnly }
    var visibleApps: [AppRecord] { document.apps.filter { !$0.hidden && $0.availability != .missing } }
    func categoryName(for app: AppRecord) -> String {
        CategoryResolver.name(for: app.categoryOverride ?? app.automaticCategory, custom: document.categories)
    }

    func start() async {
        guard !started else { return }
        started = true
        await loadDocument()
    }

    private func loadDocument() async {
        isLoading = true
        do {
            document = try await store.load()
            revision = 0
            savedRevision = 0
            saveWarning = nil
            isReadOnly = false
            recoveryWarning = nil
        } catch {
            isReadOnly = true
            recoveryWarning = "Your catalog could not be loaded. The original is preserved and changes are disabled. \(error.localizedDescription)"
        }
        isLoading = false
        publish()
        if !isReadOnly { refresh() }
    }

    func recoverBackup() async {
        guard isReadOnly else { return }
        do {
            try await store.restoreBackup()
            await loadDocument()
        } catch { operationError = "Backup recovery failed. \(error.localizedDescription)" }
    }

    /// Called only after the user confirms the archive-and-reset dialog.
    func resetCatalog() async {
        guard isReadOnly else { return }
        do {
            try await store.archiveAndReset()
            await loadDocument()
        } catch { operationError = "Reset failed. \(error.localizedDescription)" }
    }

    func refresh() {
        guard canEdit else { return }
        guard scanTask == nil else { refreshPending = true; return }
        isScanning = true
        let token = UUID()
        scanGeneration = token
        let manualRecords = document.apps.filter(\.isManual)
        let scan = scanner
        let scanRoots = roots
        let excluded = Bundle.main.bundleURL
        let worker = Task.detached(priority: .utility) {
            let manual = manualRecords.map { record -> URL in
                guard let bookmark = record.bookmark else { return record.url }
                var stale = false
                return (try? URL(resolvingBookmarkData: bookmark, options: [.withoutUI, .withoutMounting], relativeTo: nil, bookmarkDataIsStale: &stale)) ?? record.url
            }
            return try scan(scanRoots, manual, excluded)
        }
        scanTask = worker
        publish()
        Task { [weak self] in
            let result = await worker.result
            guard let self else { return }
            self.scanTask = nil
            self.isScanning = false
            guard self.scanGeneration == token else {
                self.publish()
                if self.refreshPending {
                    self.refreshPending = false
                    self.refresh()
                }
                return
            }
            let shouldDiscard = self.discardCurrentScan
            self.discardCurrentScan = false
            if !shouldDiscard {
                switch result {
                case .success(let scan):
                    // Merge current preferences, including edits made while the worker ran.
                    self.document.apps = CatalogReconciler.merge(existing: self.document.apps, scan: scan)
                    self.scanWarnings = scan.warnings
                    self.changed()
                case .failure(let error):
                    if !(error is CancellationError) { self.scanWarnings = ["Refresh failed. \(error.localizedDescription)"] }
                }
            }
            self.publish()
            if self.refreshPending {
                self.refreshPending = false
                self.refresh()
            }
        }
    }

    func stop() {
        scanGeneration = UUID()
        // Retain the canceled worker until its completion callback; cancellation is cooperative.
        scanTask?.cancel()
        refreshPending = false
        discardCurrentScan = false
        isScanning = false
    }

    func setHidden(_ hidden: Bool, id: UUID) {
        editApp(id) { $0.hidden = hidden }
    }

    func setCategory(_ category: String?, id: UUID) {
        guard category == nil || categories.contains(where: { $0.id == category }) else { return }
        editApp(id) { $0.categoryOverride = category }
    }

    private func editApp(_ id: UUID, edit: (inout AppRecord) -> Void) {
        guard canEdit, let index = document.apps.firstIndex(where: { $0.id == id }) else { return }
        edit(&document.apps[index])
        changed()
    }

    func createCategory(named name: String) {
        guard canEdit, let cleaned = validateCategoryName(name) else { return }
        document.categories.append(AppCategory(id: UUID().uuidString, name: cleaned, isBuiltIn: false))
        changed()
    }

    func renameCategory(id: String, name: String) {
        guard canEdit, let index = document.categories.firstIndex(where: { $0.id == id }),
              let cleaned = validateCategoryName(name, excluding: id) else { return }
        document.categories[index].name = cleaned
        changed()
    }

    /// Called only after category-deletion confirmation.
    func deleteCategory(id: String) {
        guard canEdit, document.categories.contains(where: { $0.id == id }) else { return }
        document.categories.removeAll { $0.id == id }
        for index in document.apps.indices where document.apps[index].categoryOverride == id {
            document.apps[index].categoryOverride = nil
        }
        changed()
    }

    private func validateCategoryName(_ name: String, excluding id: String? = nil) -> String? {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { operationError = "Enter a category name."; return nil }
        guard cleaned.count <= 100 else { operationError = "Use a category name of 100 characters or fewer."; return nil }
        guard !categories.contains(where: { $0.id != id && $0.name.compare(cleaned, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) else {
            operationError = "A category with that name already exists."
            return nil
        }
        return cleaned
    }

    func chooseApplication(locating id: UUID? = nil) {
        guard canEdit else { return }
        let panel = NSOpenPanel()
        panel.title = id == nil ? "Add Application" : "Locate Application"
        panel.prompt = id == nil ? "Add" : "Locate"
        panel.allowedContentTypes = [.applicationBundle]
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.treatsFilePackagesAsDirectories = false
        NSApp.activate(ignoringOtherApps: true)
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            Task { @MainActor in await self?.addApplication(at: url, replacing: id) }
        }
    }

    func addApplication(at url: URL, replacing id: UUID? = nil) async {
        guard canEdit else { return }
        do {
            let app = try await Task.detached(priority: .userInitiated) {
                try DiscoveryService().inspect(url: url, allowBackground: true)
            }.value
            guard canEdit else { return }
            if let existing = document.apps.first(where: {
                $0.url.standardizedFileURL == app.url.standardizedFileURL ||
                (app.fileIdentifier != nil && $0.fileIdentifier == app.fileIdentifier)
            }), existing.id != id {
                guard let id, let requested = document.apps.first(where: { $0.id == id }) else {
                    selectedAppID = existing.id
                    return
                }
                let conflicts = (existing.hidden && existing.hidden != requested.hidden) ||
                    (existing.categoryOverride != nil && existing.categoryOverride != requested.categoryOverride)
                if conflicts {
                    pendingRelocation = (app, id, existing.id)
                    relocationConfirmation = "This location already has visibility or category preferences. Reconnect \(requested.name) here and replace that duplicate entry's preferences with the missing app's settings?"
                    return
                }
                document.apps.removeAll { $0.id == existing.id }
            }
            applySelectedApplication(app, replacing: id)
        } catch { operationError = "The selected application could not be added. \(error.localizedDescription)" }
    }

    func resolveRelocation(confirmed: Bool) {
        defer { pendingRelocation = nil; relocationConfirmation = nil }
        guard confirmed, canEdit, let pending = pendingRelocation else { return }
        document.apps.removeAll { $0.id == pending.duplicateID }
        applySelectedApplication(pending.app, replacing: pending.requestedID)
    }

    private func applySelectedApplication(_ app: DiscoveredApp, replacing id: UUID?) {
        if let id, let index = document.apps.firstIndex(where: { $0.id == id }) {
            document.apps[index].url = app.url
            document.apps[index].name = app.name
            document.apps[index].bundleIdentifier = app.bundleIdentifier
            document.apps[index].version = app.version
            document.apps[index].automaticCategory = app.automaticCategory
            document.apps[index].bookmark = app.bookmark
            document.apps[index].fileIdentifier = app.fileIdentifier
            document.apps[index].isManual = true
            document.apps[index].availability = .available
            selectedAppID = id
        } else {
            let record = AppRecord(url: app.url, name: app.name, bundleIdentifier: app.bundleIdentifier,
                version: app.version, automaticCategory: app.automaticCategory, bookmark: app.bookmark,
                fileIdentifier: app.fileIdentifier, isManual: true)
            document.apps.append(record)
            selectedAppID = record.id
        }
        if let bundle = Bundle(url: app.url),
           (bundle.object(forInfoDictionaryKey: "LSUIElement") as? Bool == true ||
            bundle.object(forInfoDictionaryKey: "LSBackgroundOnly") as? Bool == true) {
            operationError = "This app runs in the background and may not show a window when opened. It has been added."
        }
        changed()
        // A worker begun before Add/Locate has an obsolete manual URL list.
        // Cancel cooperatively, discard its result, and start the replacement only after it exits.
        if let scanTask {
            discardCurrentScan = true
            refreshPending = true
            scanTask.cancel()
        } else { refresh() }
    }

    func launch(_ app: AppRecord) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.openApplication(at: app.url, configuration: configuration) { [weak self] _, error in
            guard let error else { return }
            let message = "Could not open \(app.name). Use Locate in Manage Applications if it moved. \(error.localizedDescription)"
            Task { @MainActor in
                self?.operationError = message
                self?.publish()
            }
        }
    }

    var hasUnsavedChanges: Bool { savedRevision < revision }

    func finishSaving() async -> Bool {
        if !isReadOnly { beginSaving() }
        await saveTask?.value
        return !hasUnsavedChanges
    }

    func retrySave() {
        guard canEdit else { return }
        beginSaving()
    }

    private func changed() {
        revision &+= 1
        publish()
        beginSaving()
    }

    private func beginSaving() {
        guard canEdit, saveTask == nil else { return }
        saveTask = Task { [weak self] in
            guard let self else { return }
            while self.savedRevision < self.revision {
                let savingRevision = self.revision
                let snapshot = self.document
                do {
                    try await self.store.save(snapshot)
                    self.savedRevision = savingRevision
                    self.saveWarning = nil
                } catch {
                    self.saveWarning = "Changes have not been saved. \(error.localizedDescription)"
                    if error is PreferencesError || error is DecodingError {
                        self.isReadOnly = true
                        self.recoveryWarning = "The catalog is protected because its saved data could not be validated. The original is preserved. \(error.localizedDescription)"
                        self.stop()
                    }
                    break
                }
            }
            self.saveTask = nil
            self.publish()
        }
    }

    private func publish() { didChange?() }
}
