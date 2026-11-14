import AppKit
import SwiftUI
import MenuCore

struct LauncherApplicationGrid: View {
    let apps: [AppRecord]
    let density: LauncherDensity
    @Binding var selection: UUID?
    let launch: (AppRecord) -> Void
    let hide: (AppRecord) -> Void
    let canEdit: Bool
    @FocusState private var isFocused: Bool

    private var layout: LauncherGridLayout { LauncherGridLayout(density: density) }

    var body: some View {
        GeometryReader { geometry in
            let count = layout.columnCount(for: geometry.size.width)
            ScrollViewReader { scroll in
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: LauncherGridLayout.spacing), count: count), spacing: LauncherGridLayout.spacing) {
                        ForEach(apps) { app in
                            Button {
                                isFocused = true
                                selection = app.id
                                launch(app)
                            } label: {
                                LauncherApplicationTile(app: app, density: density, height: layout.cellHeight, isSelected: selection == app.id)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Hide Application") { hide(app) }
                                    .disabled(!canEdit)
                            }
                            .focusable(false)
                            .id(app.id)
                            .help("\(app.name)\n\(app.url.path)")
                            .accessibilityLabel("Open \(app.name)")
                            .accessibilityHint(app.url.path)
                            .accessibilityAddTraits(selection == app.id ? .isSelected : [])
                        }
                    }
                    .padding(LauncherGridLayout.padding)
                }
                .contentShape(Rectangle())
                .focusable()
                .focusEffectDisabled()
                .focused($isFocused)
                .onTapGesture { isFocused = true }
                .onAppear { isFocused = true }
                .onMoveCommand { direction in move(direction, columns: count) }
                .onKeyPress(.return) {
                    guard let app = apps.first(where: { $0.id == selection }) else { return .ignored }
                    launch(app)
                    return .handled
                }
                .onChange(of: selection) { _, id in
                    if let id { scroll.scrollTo(id, anchor: .center) }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Applications grid")
                .overlay {
                    if apps.isEmpty {
                        ContentUnavailableView("No Applications", systemImage: "magnifyingglass",
                            description: Text("Try another search or category. Use Manage Applications to restore hidden or missing apps."))
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    private func move(_ direction: MoveCommandDirection, columns: Int) {
        let step: LauncherGridLayout.Direction
        switch direction {
        case .left: step = .left
        case .right: step = .right
        case .up: step = .up
        case .down: step = .down
        @unknown default: return
        }
        let current = apps.firstIndex(where: { $0.id == selection })
        if let next = layout.nextIndex(from: current, direction: step, count: apps.count, columns: columns) {
            selection = apps[next].id
        }
    }
}

private struct LauncherApplicationTile: View {
    let app: AppRecord
    let density: LauncherDensity
    let height: Double
    let isSelected: Bool
    @State private var image: NSImage?

    var body: some View {
        VStack(spacing: 8) {
            Group {
                if let image { Image(nsImage: image).resizable().scaledToFit() }
                else { Image(systemName: "app").resizable().scaledToFit().foregroundStyle(.secondary) }
            }
            .frame(width: density.iconSize, height: density.iconSize)
            .overlay(alignment: .bottomTrailing) {
                if app.availability == .unverified {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange).background(.background, in: Circle())
                }
            }
            .accessibilityHidden(true)
            Text(app.name)
                .font(.system(size: density.fontSize))
                .multilineTextAlignment(.center).lineLimit(2)
                .frame(height: density.fontSize * 2.6, alignment: .top)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .background(isSelected ? Color.accentColor.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2) }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .task(id: app.url) { image = NSWorkspace.shared.icon(forFile: app.url.path) }
    }
}
