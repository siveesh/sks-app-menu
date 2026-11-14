import SwiftUI

struct HelpView: View {
    private let content: String = {
        guard let url = Bundle.main.url(forResource: "Help", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "SK's App Menu Help\n\nOpen Manage Applications to add apps, change categories, or restore hidden apps. Refresh rescans application folders."
        }
        return text
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(content.components(separatedBy: "\n\n").enumerated()), id: \.offset) { _, block in
                    if block.hasPrefix("# ") {
                        Text(String(block.dropFirst(2))).font(.largeTitle).fontWeight(.semibold)
                    } else if block.hasPrefix("## ") {
                        Text(String(block.dropFirst(3))).font(.title2).fontWeight(.semibold).padding(.top, 8)
                    } else {
                        Text(block).font(.body).lineSpacing(4).textSelection(.enabled)
                    }
                }
            }.frame(maxWidth: 700, alignment: .leading).padding(30).frame(maxWidth: .infinity, alignment: .leading)
        }.frame(minWidth: 500, minHeight: 380)
    }
}
