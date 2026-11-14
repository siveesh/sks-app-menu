import AppKit
import SwiftUI
import MenuCore

@MainActor
final class WindowActionRelay {
    var openWindow: ((String) -> Void)?
    func open(_ id: String) {
        NSApp.activate(ignoringOtherApps: true)
        openWindow?(id)
    }
}

@MainActor
final class AppRuntime {
    static let shared = AppRuntime()
    let model: CatalogModel
    let windows = WindowActionRelay()
    private var menu: MenuController?

    private init() {
        let arguments = ProcessInfo.processInfo.arguments
        let directory: URL
        if let index = arguments.firstIndex(of: "--store-directory"), arguments.indices.contains(index + 1) {
            directory = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
        } else if let override = ProcessInfo.processInfo.environment["SK_APP_MENU_STORE_DIRECTORY"], !override.isEmpty {
            directory = URL(fileURLWithPath: override, isDirectory: true)
        } else {
            directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("com.siveesh.sksappmenu", isDirectory: true)
        }
        model = CatalogModel(store: PreferencesStore(directory: directory))
    }

    func start() {
        guard menu == nil else { return }
        menu = MenuController(model: model, windows: windows)
        Task {
            await model.start()
            if ProcessInfo.processInfo.arguments.contains("--manage") { windows.open("manage") }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        AppRuntime.shared.start()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let model = AppRuntime.shared.model
        guard model.hasUnsavedChanges else { return .terminateNow }
        Task {
            let saved = await model.finishSaving()
            if saved { sender.reply(toApplicationShouldTerminate: true); return }
            let alert = NSAlert()
            alert.messageText = "Quit with unsaved changes?"
            alert.informativeText = "Your latest visibility and category changes have not been saved. Cancel to retry saving, or quit and discard these unsaved changes."
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Quit Without Saving")
            NSApp.activate(ignoringOtherApps: true)
            sender.reply(toApplicationShouldTerminate: alert.runModal() == .alertSecondButtonReturn)
        }
        return .terminateLater
    }
    func applicationWillTerminate(_ notification: Notification) { AppRuntime.shared.model.stop() }
}

@main
struct SKsAppMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @Environment(\.openWindow) private var openWindow
    private let runtime = AppRuntime.shared

    var body: some Scene {
        let _ = installWindowRelay()
        Window("Manage Applications", id: "manage") {
            ManagementView(model: runtime.model)
                .environment(runtime.model)
        }
        .defaultSize(width: 920, height: 600)
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add Application…") { runtime.model.chooseApplication() }
                    .keyboardShortcut("o")
                    .disabled(!runtime.model.canEdit)
                Button("Manage Applications…") { runtime.windows.open("manage") }
                    .keyboardShortcut(",")
                Button("Refresh Applications") { runtime.model.refresh() }
                    .keyboardShortcut("r")
            }
            CommandGroup(replacing: .appInfo) {
                Button("About SK's App Menu") { runtime.windows.open("about") }
            }
            CommandGroup(replacing: .help) {
                Button("SK's App Menu Help") { runtime.windows.open("help") }
            }
        }
        Window("Categories", id: "categories") {
            CategoryManagementView(model: runtime.model)
        }
        .defaultSize(width: 480, height: 430)
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        Window("SK's App Menu Help", id: "help") { HelpView() }
            .defaultSize(width: 660, height: 620)
            .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        Window("About SK's App Menu", id: "about") { AboutView() }
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
    }

    private func installWindowRelay() {
        runtime.windows.openWindow = { id in openWindow(id: id) }
    }
}
