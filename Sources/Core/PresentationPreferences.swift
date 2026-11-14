import Foundation

public enum LauncherDensity: String, CaseIterable, Codable, Sendable, Identifiable {
    case compact, comfortable, spacious

    public var id: Self { self }

    public var title: String {
        switch self {
        case .compact: "Compact"
        case .comfortable: "Comfortable"
        case .spacious: "Spacious"
        }
    }

    public var iconSize: Double {
        switch self {
        case .compact: 20
        case .comfortable: 28
        case .spacious: 40
        }
    }

    public var rowHeight: Double {
        switch self {
        case .compact: 32
        case .comfortable: 44
        case .spacious: 60
        }
    }

    public var fontSize: Double {
        switch self {
        case .compact: 13
        case .comfortable: 14
        case .spacious: 16
        }
    }

    public init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: value) ?? .comfortable
    }
}

public struct PresentationPreferences: Codable, Sendable, Equatable {
    public var showInDock: Bool
    public var launcherDensity: LauncherDensity
    public var hideRefreshWarnings: Bool

    public init(showInDock: Bool = false, launcherDensity: LauncherDensity = .comfortable, hideRefreshWarnings: Bool = false) {
        self.showInDock = showInDock
        self.launcherDensity = launcherDensity
        self.hideRefreshWarnings = hideRefreshWarnings
    }

    private enum CodingKeys: String, CodingKey { case showInDock, launcherDensity, hideRefreshWarnings }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showInDock = try container.decodeIfPresent(Bool.self, forKey: .showInDock) ?? false
        launcherDensity = try container.decodeIfPresent(LauncherDensity.self, forKey: .launcherDensity) ?? .comfortable
        hideRefreshWarnings = try container.decodeIfPresent(Bool.self, forKey: .hideRefreshWarnings) ?? false
    }
}
