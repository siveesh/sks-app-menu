import AppKit
import SwiftUI
import MenuCore

struct LauncherView: View {
    @Bindable var model: CatalogModel
    let windows: WindowActionRelay
    @State private var categorySelection: LauncherCategorySelection? = .all
    @State private var search = ""
    @State private var selection: UUID?

    private var category: String? {
        if case .category(let name) = categorySelection { return name }
        return nil
    }

    private var categoryNames: [String] {
        Set(model.visibleApps.map { model.categoryName(for: $0) })
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
    private var apps: [AppRecord] { model.launcherApps(category: category, query: search) }

    var body: some View {
        NavigationSplitView {
            LauncherSidebar(categories: categoryNames, selection: $categorySelection)
                .navigationSplitViewColumnWidth(min: 150, ideal: 190, max: 260)
        } detail: {
            VStack(spacing: 0) {
                LauncherWarnings(model: model, manage: { windows.open("manage") })
                LauncherApplicationList(apps: apps, density: model.document.presentation.launcherDensity,
                    selection: $selection, launch: model.launch)
                HStack {
                    Text("\(apps.count) applications").monospacedDigit()
                    Spacer()
                    if model.isScanning { ProgressView().controlSize(.mini); Text("Refreshing…") }
                }
                .font(.caption).foregroundStyle(.secondary).padding(.horizontal).padding(.vertical, 8)
            }
            .navigationTitle(category ?? "All Applications")
        }
        .frame(minWidth: 520, minHeight: 360)
        .searchable(text: $search, prompt: "Search name, category, or location")
        .toolbar {
            ToolbarItem {
                Picker("Display size", selection: Binding(get: { model.document.presentation.launcherDensity }, set: model.setLauncherDensity)) {
                    ForEach(LauncherDensity.allCases) { Text($0.title).tag($0) }
                }
                .help("Launcher icon, text, and row size")
                .disabled(!model.canEdit)
            }
            ToolbarItemGroup {
                Button { model.refresh() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
                    .help("Refresh applications").disabled(!model.canEdit)
                Button { model.chooseApplication() } label: { Label("Add Application", systemImage: "plus") }
                    .help("Add an application").disabled(!model.canEdit)
                Button { windows.open("manage") } label: { Label("Manage Applications", systemImage: "slider.horizontal.3") }
                    .help("Manage visibility, categories, and recovery")
            }
        }
        .onChange(of: categoryNames) { _, names in
            if let category, !names.contains(category) { categorySelection = .all }
        }
        .onChange(of: apps.map(\.id)) { _, ids in
            if let selection, !ids.contains(selection) { self.selection = nil }
        }
        .alert("Application Notice", isPresented: Binding(get: { model.operationError != nil }, set: { if !$0 { model.operationError = nil } })) {
            Button("Manage Applications…") { model.operationError = nil; windows.open("manage") }
            Button("OK", role: .cancel) { model.operationError = nil }
        } message: { Text(model.operationError ?? "") }
    }
}

private enum LauncherCategorySelection: Hashable {
    case all
    case category(String)
}

private struct LauncherSidebar: View {
    let categories: [String]
    @Binding var selection: LauncherCategorySelection?
    var body: some View {
        List(selection: $selection) {
            Label("All Applications", systemImage: "square.grid.2x2").tag(LauncherCategorySelection.all)
            Section("Categories") {
                ForEach(categories, id: \.self) { category in
                    Label(category, systemImage: "folder").tag(LauncherCategorySelection.category(category))
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Applications")
    }
}

private struct LauncherApplicationList: View {
    let apps: [AppRecord]
    let density: LauncherDensity
    @Binding var selection: UUID?
    let launch: (AppRecord) -> Void

    var body: some View {
        List(selection: $selection) {
            ForEach(apps) { app in
                Button { selection = app.id; launch(app) } label: {
                    LauncherApplicationRow(app: app, density: density)
                }
                .buttonStyle(.plain)
                .tag(app.id)
                .help("\(app.name)\n\(app.url.path)")
                .accessibilityLabel("Open \(app.name)")
                .accessibilityHint(app.url.path)
            }
        }
        .listStyle(.inset)
        .environment(\.defaultMinListRowHeight, density.rowHeight)
        .onKeyPress(.return) {
            guard let app = apps.first(where: { $0.id == selection }) else { return .ignored }
            launch(app)
            return .handled
        }
        .overlay {
            if apps.isEmpty {
                ContentUnavailableView("No Applications", systemImage: "magnifyingglass",
                    description: Text("Try another search or category. Use Manage Applications to restore hidden or missing apps."))
                    .allowsHitTesting(false)
            }
        }
    }
}

private struct LauncherApplicationRow: View {
    let app: AppRecord
    let density: LauncherDensity
    @State private var image: NSImage?
    var body: some View {
        HStack(spacing: density == .compact ? 8 : 12) {
            Group {
                if let image { Image(nsImage: image).resizable().scaledToFit() }
                else { Image(systemName: "app").resizable().scaledToFit().foregroundStyle(.secondary) }
            }
            .frame(width: density.iconSize, height: density.iconSize).accessibilityHidden(true)
            Text(app.name).font(.system(size: density.fontSize)).fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            if app.availability == .unverified {
                Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary)
                    .accessibilityLabel("Location not verified")
            }
        }
        .frame(maxWidth: .infinity, minHeight: density.rowHeight, alignment: .leading)
        .contentShape(Rectangle())
        .task(id: app.url) { image = NSWorkspace.shared.icon(forFile: app.url.path) }
    }
}

private struct LauncherWarnings: View {
    let model: CatalogModel
    let manage: () -> Void
    var body: some View {
        if let warning = model.launcherWarning {
            HStack(alignment: .top) {
                Label(warning, systemImage: "exclamationmark.triangle")
                    .font(.callout).textSelection(.enabled)
                Spacer(minLength: 8)
                if model.recoveryWarning == nil && model.saveWarning == nil && model.dockWarning == nil {
                    Button("Hide") { model.setHideRefreshWarnings(true) }
                        .help("Hide refresh warnings in the menu and launcher. Change this in Manage Applications.")
                        .disabled(!model.canEdit)
                }
                Button("Manage…", action: manage)
            }
            .padding().background(.orange.opacity(0.12))
        }
    }
}
