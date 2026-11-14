import Foundation

/// Stable identifiers deliberately remain independent of presentation names.
public enum CategoryResolver {
    public static let builtIn: [AppCategory] = [
        ("business", "Business"), ("developer-tools", "Developer Tools"),
        ("education", "Education"), ("entertainment", "Entertainment"),
        ("finance", "Finance"), ("games", "Games"),
        ("graphics-design", "Graphics & Design"), ("healthcare-fitness", "Health & Fitness"),
        ("lifestyle", "Lifestyle"), ("medical", "Medical"), ("music", "Music"),
        ("news", "News"), ("photography", "Photography"), ("productivity", "Productivity"),
        ("reference", "Reference"), ("social-networking", "Social Networking"),
        ("sports", "Sports"), ("travel", "Travel"), ("utilities", "Utilities"),
        ("video", "Video"), ("weather", "Weather"), ("other", "Other")
    ].map { AppCategory(id: $0.0, name: $0.1, isBuiltIn: true) }

    public static func category(for metadata: String?) -> String {
        guard let metadata, metadata.hasPrefix("public.app-category.") else { return "other" }
        let suffix = String(metadata.dropFirst("public.app-category.".count))
        if builtIn.contains(where: { $0.id == suffix }) { return suffix }
        let gameTypes: Set<String> = ["action-games", "adventure-games", "arcade-games", "board-games", "card-games", "casino-games", "dice-games", "educational-games", "family-games", "kids-games", "music-games", "puzzle-games", "racing-games", "role-playing-games", "simulation-games", "sports-games", "strategy-games", "trivia-games", "word-games"]
        return gameTypes.contains(suffix) ? "games" : "other"
    }

    public static func name(for id: String, custom: [AppCategory] = []) -> String {
        builtIn.first(where: { $0.id == id })?.name ?? custom.first(where: { $0.id == id })?.name ?? "Other"
    }
}
