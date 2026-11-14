import Foundation

public enum Availability: String, Codable, Sendable { case available, missing, unverified }

public struct AppRecord: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var url: URL
    public var name: String
    public var bundleIdentifier: String?
    public var version: String
    public var automaticCategory: String
    public var bookmark: Data?
    public var fileIdentifier: String?
    public var isManual: Bool
    public var hidden: Bool
    public var categoryOverride: String?
    public var availability: Availability

    public init(id: UUID = UUID(), url: URL, name: String, bundleIdentifier: String? = nil, version: String = "", automaticCategory: String = "other", bookmark: Data? = nil, fileIdentifier: String? = nil, isManual: Bool = false, hidden: Bool = false, categoryOverride: String? = nil, availability: Availability = .available) {
        self.id = id; self.url = url; self.name = name; self.bundleIdentifier = bundleIdentifier
        self.version = version; self.automaticCategory = automaticCategory; self.bookmark = bookmark
        self.fileIdentifier = fileIdentifier; self.isManual = isManual; self.hidden = hidden
        self.categoryOverride = categoryOverride; self.availability = availability
    }
}

public struct DiscoveredApp: Sendable, Codable, Equatable {
    public var url: URL
    public var name: String
    public var bundleIdentifier: String?
    public var version: String
    public var automaticCategory: String
    public var bookmark: Data?
    public var fileIdentifier: String?
    public var isManual: Bool

    public init(url: URL, name: String, bundleIdentifier: String? = nil, version: String = "", automaticCategory: String = "other", bookmark: Data? = nil, fileIdentifier: String? = nil, isManual: Bool = false) {
        self.url = url; self.name = name; self.bundleIdentifier = bundleIdentifier
        self.version = version; self.automaticCategory = automaticCategory
        self.bookmark = bookmark; self.fileIdentifier = fileIdentifier; self.isManual = isManual
    }
}

public struct AppCategory: Identifiable, Codable, Sendable, Equatable, Hashable {
    public var id: String
    public var name: String
    public var isBuiltIn: Bool
    public init(id: String = UUID().uuidString, name: String, isBuiltIn: Bool = false) {
        self.id = id; self.name = name; self.isBuiltIn = isBuiltIn
    }
}

public struct CatalogDocument: Codable, Sendable, Equatable {
    public var schemaVersion: Int
    public var apps: [AppRecord]
    public var categories: [AppCategory]
    public var presentation: PresentationPreferences

    public init(schemaVersion: Int = 1, apps: [AppRecord] = [], categories: [AppCategory] = [], presentation: PresentationPreferences = PresentationPreferences()) {
        self.schemaVersion = schemaVersion; self.apps = apps; self.categories = categories
        self.presentation = presentation
    }

    private enum CodingKeys: String, CodingKey { case schemaVersion, apps, categories, presentation }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        apps = try container.decode([AppRecord].self, forKey: .apps)
        categories = try container.decode([AppCategory].self, forKey: .categories)
        presentation = try container.decodeIfPresent(PresentationPreferences.self, forKey: .presentation) ?? PresentationPreferences()
    }
}

public struct ScanResult: Codable, Sendable, Equatable {
    public var apps: [DiscoveredApp]
    public var failedRoots: [URL]
    public var warnings: [String]
    public init(apps: [DiscoveredApp] = [], failedRoots: [URL] = [], warnings: [String] = []) {
        self.apps = apps; self.failedRoots = failedRoots; self.warnings = warnings
    }
}
