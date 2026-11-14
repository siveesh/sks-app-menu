import AppKit
import MenuCore

/// The only imperative menu bridge. All catalog values remain owned by CatalogModel.
@MainActor
final class MenuController: NSObject, NSMenuDelegate {
    private let model: CatalogModel
    private let windows: WindowActionRelay
    private let statusItem: NSStatusItem
    let menu = NSMenu()
    private var isTracking = false
    private var needsRebuild = true
    private var icons: [String: NSImage] = [:]

    init(model: CatalogModel, windows: WindowActionRelay) {
        self.model = model
        self.windows = windows
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        statusItem.button?.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "SK's App Menu")
        statusItem.button?.toolTip = "SK's App Menu"
        statusItem.button?.setAccessibilityLabel("SK's App Menu")
        statusItem.menu = menu
        menu.delegate = self
        menu.autoenablesItems = false
        model.didChange = { [weak self] in self?.invalidate() }
        rebuild()
    }

    private func invalidate() {
        needsRebuild = true
        if !isTracking { rebuild() }
        if model.operationError != nil { windows.open("manage") }
    }

    func menuWillOpen(_ menu: NSMenu) {
        if menu === self.menu {
            if needsRebuild { rebuild() }
            isTracking = true

        }
    }

    func menuDidClose(_ menu: NSMenu) {
        guard menu === self.menu else { return }
        isTracking = false
        if needsRebuild { rebuild() }
    }

    private func rebuild() {
        guard !isTracking else { needsRebuild = true; return }
        needsRebuild = false
        menu.removeAllItems()
        if model.isLoading { message("Loading…") }
        if model.isScanning { message("Refreshing…") }
        if model.isReadOnly { command("Recover Catalog…", action: #selector(manage)) }
        if model.saveWarning != nil { command("Unsaved Changes…", action: #selector(manage)) }
        if !model.scanWarnings.isEmpty { command("Refresh Warnings…", action: #selector(manage)) }
        let apps = model.visibleApps
        let grouped = Dictionary(grouping: apps, by: { model.categoryName(for: $0) })
        for category in grouped.keys.sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending }) {
            let item = NSMenuItem(title: compact(category), action: nil, keyEquivalent: "")
            let submenu = NSMenu(title: category)
            submenu.autoenablesItems = false
            submenu.delegate = self
            for app in (grouped[category] ?? []).sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending }) {
                let duplicate = apps.filter { $0.name == app.name }.count > 1
                let title = duplicate ? "\(app.name) — \(app.url.deletingLastPathComponent().lastPathComponent)" : app.name
                let child = NSMenuItem(title: compact(title), action: #selector(launch(_:)), keyEquivalent: "")
                child.target = self
                child.representedObject = app.id
                child.toolTip = "\(app.name)\n\(app.url.path)"
                // Install the native icon before AppKit lays out the submenu.
                child.image = icon(for: app)
                child.preferredImageVisibility = .visible
                submenu.addItem(child)
            }
            item.toolTip = category
            item.submenu = submenu
            menu.addItem(item)
        }
        if apps.isEmpty && !model.isLoading { message("No visible applications") }
        menu.addItem(.separator())
        command("Add Application…", action: #selector(add), key: "o", enabled: model.canEdit)
        command("Manage Applications…", action: #selector(manage), key: ",")
        command("Refresh", action: #selector(refresh), key: "r", enabled: model.canEdit)
        menu.addItem(.separator())
        command("About…", action: #selector(about))
        command("Help", action: #selector(help), key: "?")
        menu.addItem(.separator())
        command("Quit", action: #selector(quit), key: "q")
    }

    /// Keep native intrinsic sizing while preventing a long path/name from widening the menu.
    private func compact(_ title: String) -> String {
        let font = NSFont.menuFont(ofSize: 0)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        var label = String(title.prefix(80))
        if label == title && (label as NSString).size(withAttributes: attributes).width <= 240 { return label }
        while !label.isEmpty && ((label + "…") as NSString).size(withAttributes: attributes).width > 240 { label.removeLast() }
        return label + "…"
    }

    private func icon(for app: AppRecord) -> NSImage {
        let key = app.url.path + "|" + app.version
        if let icon = icons[key] { return icon }
        let image = NSWorkspace.shared.icon(forFile: app.url.path)
        image.size = NSSize(width: 16, height: 16)
        if icons.count > 600 { icons.removeAll(keepingCapacity: true) }
        icons[key] = image
        return image
    }

    private func message(_ text: String) {
        let item = NSMenuItem(title: text, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    private func command(_ title: String, action: Selector, key: String = "", enabled: Bool = true) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        item.isEnabled = enabled
        menu.addItem(item)
    }

    @objc private func launch(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID,
              let app = model.document.apps.first(where: { $0.id == id }) else { return }
        model.launch(app)
    }
    @objc private func add() { windows.open("manage"); model.chooseApplication() }
    @objc private func manage() { windows.open("manage") }
    @objc private func refresh() { model.refresh() }
    @objc private func about() { windows.open("about") }
    @objc private func help() { windows.open("help") }
    @objc private func quit() { NSApp.terminate(nil) }
}
