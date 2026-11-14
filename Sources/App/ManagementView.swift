import AppKit
import SwiftUI
import MenuCore

struct ManagementView: View {
    @Bindable var model: CatalogModel
    let openLauncher: () -> Void
    @Environment(\.openWindow) private var openWindow
    @State private var search = ""
    @State private var filter = AppFilter.all
    @State private var confirmReset = false
    @State private var confirmRecovery = false

    private enum AppFilter: String, CaseIterable, Identifiable {
        case all = "All", visible = "Visible", hidden = "Hidden", missing = "Missing"
        var id: Self { self }
    }

    private var filteredApps: [AppRecord] {
        model.document.apps.filter { app in
            let matches: Bool
            switch filter {
            case .all: matches = true
            case .visible: matches = !app.hidden && app.availability != .missing
            case .hidden: matches = app.hidden
            case .missing: matches = app.availability == .missing
            }
            return matches && (search.isEmpty || app.name.localizedCaseInsensitiveContains(search) ||
                app.url.path.localizedCaseInsensitiveContains(search) || model.categoryName(for: app).localizedCaseInsensitiveContains(search))
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        VStack(spacing: 0) {
            warnings
            appearance
            HStack {
                Toggle("Hide Refresh Warnings", isOn: Binding(get: { model.document.presentation.hideRefreshWarnings }, set: model.setHideRefreshWarnings))
                    .toggleStyle(.checkbox).disabled(!model.canEdit)
                Text("Hide notices in the menu and launcher. Details remain above.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
            }.padding(.horizontal).padding(.bottom, 10)
            HStack {
                Picker("Show applications", selection: $filter) {
                    ForEach(AppFilter.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).frame(maxWidth: 420)
                Spacer()
                if model.isScanning { ProgressView().controlSize(.small); Text("Refreshing…").foregroundStyle(.secondary) }
                Text("\(filteredApps.count) apps").foregroundStyle(.secondary).monospacedDigit()
            }.padding()
            Divider()
            HSplitView {
                applicationList
                    .frame(minWidth: 390, idealWidth: 530, maxHeight: .infinity)
                applicationDetail
                    .frame(minWidth: 280, idealWidth: 310, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(minWidth: 780, maxWidth: .infinity, minHeight: 460, maxHeight: .infinity, alignment: .top)
        .searchable(text: $search, prompt: "Search name, category, or location")
        .toolbar {
            ToolbarItemGroup {
                Button { model.chooseApplication() } label: { Label("Add Application", systemImage: "plus") }
                    .help("Browse for an application").disabled(!model.canEdit)
                Button { model.refresh() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
                    .help("Refresh applications").disabled(!model.canEdit)
                Button { openWindow(id: "categories") } label: { Label("Categories", systemImage: "folder") }
                Button { openWindow(id: "help") } label: { Label("Help", systemImage: "questionmark.circle") }
            }
        }
        .alert("Application Notice", isPresented: Binding(get: { model.operationError != nil }, set: { if !$0 { model.operationError = nil } })) {
            Button("OK", role: .cancel) { model.operationError = nil }
        } message: { Text(model.operationError ?? "") }
        .confirmationDialog("Reconnect this application?", isPresented: Binding(get: { model.relocationConfirmation != nil }, set: { if !$0 { model.resolveRelocation(confirmed: false) } })) {
            Button("Reconnect and Use Missing App's Settings") { model.resolveRelocation(confirmed: true) }
            Button("Cancel", role: .cancel) { model.resolveRelocation(confirmed: false) }
        } message: { Text(model.relocationConfirmation ?? "") }
        .confirmationDialog("Restore the last saved backup?", isPresented: $confirmRecovery) {
            Button("Restore Backup") { Task { await model.recoverBackup() } }
        } message: { Text("The current catalog is preserved by recovery. Preferences made after the backup may need to be entered again.") }
        .confirmationDialog("Archive this catalog and start again?", isPresented: $confirmReset) {
            Button("Archive and Reset", role: .destructive) { Task { await model.resetCatalog() } }
        } message: { Text("The original catalog will be archived. App visibility and category settings will start fresh. Installed apps are unaffected.") }
    }

    private var appearance: some View {
        HStack(spacing: 18) {
            Text("Appearance").font(.headline)
            Toggle("Show in Dock", isOn: Binding(get: { model.effectiveShowInDock }, set: model.setShowInDock))
                .toggleStyle(.checkbox)
            Picker("Launcher size", selection: Binding(get: { model.document.presentation.launcherDensity }, set: model.setLauncherDensity)) {
                ForEach(LauncherDensity.allCases) { Text($0.title).tag($0) }
            }.frame(maxWidth: 260)
            Spacer()
            Button("Open Launcher…", action: openLauncher)
        }
        .padding(.horizontal).padding(.vertical, 10)
        .disabled(!model.canEdit)
    }

    private var applicationList: some View {
        List(selection: $model.selectedAppID) {
            ForEach(filteredApps) { app in
                HStack(spacing: 10) {
                    ApplicationIcon(url: app.url)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(app.name).fontWeight(.medium)
                        Text(app.url.path).font(.caption).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(model.categoryName(for: app)).font(.caption)
                        Text(status(for: app)).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 3)
                .tag(app.id)
                .accessibilityElement(children: .combine)
                .contextMenu {
                    Button("Open") { model.launch(app) }.disabled(app.availability == .missing)
                    Button(app.hidden ? "Show in Menu" : "Hide from Menu") { model.setHidden(!app.hidden, id: app.id) }.disabled(!model.canEdit)
                    if app.availability == .missing { Button("Locate…") { model.chooseApplication(locating: app.id) }.disabled(!model.canEdit) }
                }
            }
        }
        .overlay {
            if filteredApps.isEmpty {
                ContentUnavailableView(search.isEmpty ? "No Applications" : "No Matches", systemImage: "square.grid.2x2", description: Text(search.isEmpty ? "Add an application or refresh the catalog." : "Try another name, category, or location."))
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder private var applicationDetail: some View {
        if let app = model.document.apps.first(where: { $0.id == model.selectedAppID }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        ApplicationIcon(url: app.url, size: 48)
                        VStack(alignment: .leading) {
                            Text(app.name).font(.title2).fontWeight(.semibold).textSelection(.enabled)
                            Text(app.version.isEmpty ? "Version unavailable" : app.version).foregroundStyle(.secondary)
                        }
                    }
                    LabeledContent("Availability", value: app.availability == .available ? "Available" : app.availability == .missing ? "Missing" : "Not verified")
                    Toggle("Show in menu", isOn: Binding(get: { !app.hidden }, set: { model.setHidden(!$0, id: app.id) }))
                        .disabled(!model.canEdit)
                    Picker("Category", selection: Binding(get: { app.categoryOverride ?? "" }, set: { model.setCategory($0.isEmpty ? nil : $0, id: app.id) })) {
                        Text("Automatic (\(CategoryResolver.name(for: app.automaticCategory, custom: model.document.categories)))").tag("")
                        Divider()
                        ForEach(model.categories) { Text($0.name).tag($0.id) }
                    }.disabled(!model.canEdit)
                    if app.categoryOverride != nil {
                        Button("Use Automatic Category") { model.setCategory(nil, id: app.id) }.disabled(!model.canEdit)
                    }
                    Divider()
                    Text("Location").font(.headline)
                    Text(app.url.path).font(.callout).textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                    if let identifier = app.bundleIdentifier { Text(identifier).font(.caption).foregroundStyle(.secondary).textSelection(.enabled) }
                    if app.isManual { Label("Added manually", systemImage: "plus.circle").font(.caption).foregroundStyle(.secondary) }
                    if app.availability == .missing {
                        Text("This app was not found. Locate it to keep its visibility and category settings.").foregroundStyle(.secondary)
                        Button("Locate Application…") { model.chooseApplication(locating: app.id) }.disabled(!model.canEdit)
                    } else {
                        Button("Open Application") { model.launch(app) }
                        Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([app.url]) }
                    }
                    if app.availability == .unverified {
                        Text("Its location could not be scanned. The previous entry is retained; opening it may fail.").font(.caption).foregroundStyle(.secondary)
                    }
                    if app.hidden { Text("Hidden apps stay in this list. Turn on Show in menu to restore this app.").font(.caption).foregroundStyle(.secondary) }
                }.padding(22).frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            ContentUnavailableView("Select an Application", systemImage: "cursorarrow", description: Text("Control its visibility and category, or locate a missing app."))
        }
    }

    private func status(for app: AppRecord) -> String {
        if app.availability == .missing { return app.hidden ? "Hidden · Missing" : "Missing" }
        if app.availability == .unverified { return app.hidden ? "Hidden · Not verified" : "Not verified" }
        return app.hidden ? "Hidden" : "Visible"
    }

    @ViewBuilder private var warnings: some View {
        if let warning = model.dockWarning {
            Label(warning, systemImage: "exclamationmark.triangle")
                .font(.callout).padding().frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.12))
        }
        if let warning = model.recoveryWarning {
            VStack(alignment: .leading, spacing: 10) {
                Label("Catalog is read-only", systemImage: "exclamationmark.triangle").fontWeight(.semibold)
                Text(warning).font(.callout).textSelection(.enabled)
                HStack {
                    Button("Restore Backup…") { confirmRecovery = true }
                    Button("Archive and Reset…") { confirmReset = true }
                }
            }.padding().frame(maxWidth: .infinity, alignment: .leading).background(.orange.opacity(0.12))
        }
        if let warning = model.saveWarning {
            HStack {
                Label(warning, systemImage: "exclamationmark.triangle").font(.callout)
                Spacer()
                Button("Retry") { model.retrySave() }
            }.padding().background(.orange.opacity(0.12))
        }
        if !model.scanWarnings.isEmpty {
            DisclosureGroup("Refresh warnings (\(model.scanWarnings.count))") {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(model.scanWarnings.enumerated()), id: \.offset) { _, warning in Text(warning).font(.caption).textSelection(.enabled) }
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 5)
            }.padding(.horizontal).padding(.vertical, 8)
        }
    }
}

private struct ApplicationIcon: View {
    let url: URL
    var size: CGFloat = 28
    @State private var image: NSImage?
    var body: some View {
        Group {
            if let image { Image(nsImage: image).resizable().scaledToFit() }
            else { Image(systemName: "app").resizable().scaledToFit().foregroundStyle(.secondary) }
        }
        .frame(width: size, height: size).accessibilityHidden(true)
        .task(id: url) { image = NSWorkspace.shared.icon(forFile: url.path) }
    }
}
