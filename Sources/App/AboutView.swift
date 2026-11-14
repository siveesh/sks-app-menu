import AppKit
import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 24) {
                HStack(spacing: 32) {
                    if let logo = NSImage(named: "Logo1") {
                        Image(nsImage: logo).resizable().scaledToFit().frame(width: 100, height: 100)
                    }
                    Divider().frame(height: 74).opacity(0.3)
                    if let logo = NSImage(named: "Logo2") {
                        if colorScheme == .dark {
                            Image(nsImage: logo).resizable().scaledToFit().frame(width: 100, height: 100).colorInvert()
                        } else {
                            Image(nsImage: logo).resizable().scaledToFit().frame(width: 100, height: 100)
                        }
                    }
                }.accessibilityHidden(true)
                VStack(spacing: 6) {
                    Image(nsImage: NSApp.applicationIconImage)
                        .resizable().scaledToFit().frame(width: 56, height: 56)
                        .accessibilityHidden(true)
                    Text("SK's App Menu").font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Your applications, organized in the menu bar.").foregroundStyle(.secondary)
                    Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0") (Build \(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"))")
                        .font(.system(.caption, design: .monospaced)).foregroundStyle(.tertiary)
                }
                VStack(spacing: 8) {
                    Text("© 2026 Siveesh Kodapully").font(.callout).foregroundStyle(.secondary)
                    HStack(spacing: 14) {
                        Link("www.siveesh.com", destination: URL(string: "https://www.siveesh.com")!)
                        Text("•").foregroundStyle(.tertiary)
                        Link("siveesh@learnwithsk.com", destination: URL(string: "mailto:siveesh@learnwithsk.com")!)
                    }.font(.callout)
                }
            }.padding(36)
        }.frame(width: 460, height: 440)
    }
}
