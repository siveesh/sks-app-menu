import SwiftUI

struct HelpView: View {
    private let content: String = {
        guard let url = Bundle.main.url(forResource: "Help", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            return "SK's App Menu Help\n\nOpen Manage Applications to add apps, change categories, or restore hidden apps. Refresh rescans application folders."
        }
        return text
    }()

    private var blocks: [String] { content.components(separatedBy: "\n\n").filter { !$0.isEmpty } }

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                        helpBlock(block).id(index)
                    }
                }
                .textSelection(.enabled)
                .frame(maxWidth: 700, alignment: .leading).padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toolbar {
                ToolbarItem {
                    Menu("Contents") {
                        ForEach(blocks.indices.filter { blocks[$0].hasPrefix("## ") }, id: \.self) { index in
                            Button(String(blocks[index].dropFirst(3))) { reader.scrollTo(index, anchor: .top) }
                        }
                    }
                }
            }
        }.frame(minWidth: 500, minHeight: 380)
    }

    @ViewBuilder private func helpBlock(_ block: String) -> some View {
        if block.hasPrefix("# ") {
            Text(String(block.dropFirst(2))).font(.largeTitle).fontWeight(.semibold)
        } else if block.hasPrefix("## ") {
            Text(String(block.dropFirst(3))).font(.title2).fontWeight(.semibold).padding(.top, 8)
        } else if block.hasPrefix("### ") {
            Text(String(block.dropFirst(4))).font(.headline).padding(.top, 5)
        } else if block.hasPrefix("```") {
            Text(block.components(separatedBy: "\n").dropFirst().dropLast().joined(separator: "\n"))
                .font(.system(.callout, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        } else {
            let formatted = (try? AttributedString(markdown: block, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(block)
            Text(formatted).font(.body).lineSpacing(4)
        }
    }
}
