import Foundation

public enum PreferencesError: LocalizedError, Sendable {
    case recoveryRequired, newerSchema(Int), invalidData(String), oversized
    public var errorDescription: String? {
        switch self {
        case .recoveryRequired: "Settings are protected. Restore a backup or archive and reset them before saving."
        case .newerSchema(let version): "These settings use a newer format (\(version)). Open them with a newer app, or archive and reset."
        case .invalidData(let reason): "Settings could not be validated: \(reason). The original file has been preserved."
        case .oversized: "The settings file exceeds the safe size limit. The original file has been preserved."
        }
    }
}

/// One serialized owner for the store. Recovery never silently replaces corrupt data.
public actor PreferencesStore {
    private let directory: URL
    private var locked = false
    private var checked = false
    private let limit = 20 * 1_024 * 1_024
    private var file: URL { directory.appendingPathComponent("catalog.json") }
    private var backup: URL { directory.appendingPathComponent("catalog-backup.json") }
    public init(directory: URL) { self.directory = directory }

    public func load() throws -> CatalogDocument {
        do {
            let result = FileManager.default.fileExists(atPath: file.path) ? try decode(file) : CatalogDocument()
            checked = true; locked = false
            return result
        } catch {
            checked = true; locked = true
            throw error
        }
    }

    public func save(_ document: CatalogDocument) throws {
        if !checked { _ = try load() }
        guard !locked else { throw PreferencesError.recoveryRequired }
        try validate(document)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(document)
        guard data.count <= limit else { throw PreferencesError.oversized }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        // Validate the previous file again: an externally corrupted file is never overwritten.
        if FileManager.default.fileExists(atPath: file.path) {
            do { _ = try decode(file) } catch { locked = true; throw error }
            try Data(contentsOf: file).write(to: backup, options: .atomic)
        }
        try data.write(to: file, options: .atomic)
        // First successful save is also recoverable.
        if !FileManager.default.fileExists(atPath: backup.path) {
            try data.write(to: backup, options: .atomic)
        }
    }

    public func restoreBackup() throws {
        _ = try decode(backup)
        let data = try Data(contentsOf: backup)
        try archiveOriginal()
        try data.write(to: file, options: .atomic)
        locked = false; checked = true
    }

    public func archiveAndReset() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try archiveOriginal()
        try JSONEncoder().encode(CatalogDocument()).write(to: file, options: .atomic)
        locked = false; checked = true
    }

    private func archiveOriginal() throws {
        if FileManager.default.fileExists(atPath: file.path) {
            let archive = directory.appendingPathComponent("catalog-archive-\(UUID().uuidString).json")
            try FileManager.default.copyItem(at: file, to: archive)
        }
    }

    private func decode(_ url: URL) throws -> CatalogDocument {
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        guard (attrs[.size] as? NSNumber)?.intValue ?? Int.max <= limit else { throw PreferencesError.oversized }
        let data = try Data(contentsOf: url)
        guard data.count <= limit else { throw PreferencesError.oversized }
        // Decode schema first so forward-format errors remain actionable even if fields changed.
        struct Header: Decodable { var schemaVersion: Int }
        let decoder = JSONDecoder()
        let header = try decoder.decode(Header.self, from: data)
        guard header.schemaVersion == 1 else { throw PreferencesError.newerSchema(header.schemaVersion) }
        let doc = try decoder.decode(CatalogDocument.self, from: data)
        try validate(doc)
        return doc
    }

    private func validate(_ doc: CatalogDocument) throws {
        guard doc.schemaVersion == 1 else { throw PreferencesError.newerSchema(doc.schemaVersion) }
        guard doc.apps.count <= 50_000, doc.categories.count <= 1_024 else { throw PreferencesError.oversized }
        var ids = Set<String>(), names = Set<String>()
        let builtIn = Set(CategoryResolver.builtIn.map(\.id))
        // This newly introduced built-in name may already exist as a custom category
        // in schema-1 catalogs. Preserve those records; UI still rejects new duplicate names.
        let builtInNames = Set(CategoryResolver.builtIn.filter { $0.id != "ios-apps" }.map { $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) })
        for category in doc.categories {
            let name = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            guard !category.id.isEmpty, !name.isEmpty, name.count <= 100, name == category.name,
                  !category.isBuiltIn, !builtIn.contains(category.id), !builtInNames.contains(key),
                  ids.insert(category.id).inserted, names.insert(key).inserted else {
                throw PreferencesError.invalidData("invalid or duplicate category")
            }
        }
        var appIDs = Set<UUID>()
        for app in doc.apps {
            guard appIDs.insert(app.id).inserted, app.url.isFileURL, !app.name.isEmpty,
                  app.bookmark?.count ?? 0 <= 1_024 * 1_024 else {
                throw PreferencesError.invalidData("invalid application record")
            }
            if let category = app.categoryOverride, !builtIn.contains(category), !ids.contains(category) {
                throw PreferencesError.invalidData("application refers to an unknown category")
            }
        }
    }
}
