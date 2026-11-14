import AppKit
import SwiftUI

/// The only activation-policy boundary. SwiftUI owns creation of the singleton launcher.
@MainActor
final class DockPresenceController {
    private let model: CatalogModel
    private let windows: WindowActionRelay
    private let setPolicy: (NSApplication.ActivationPolicy) -> Bool
    private(set) var isEnabled = false

    init(model: CatalogModel, windows: WindowActionRelay,
         setPolicy: @escaping (NSApplication.ActivationPolicy) -> Bool = { NSApp.setActivationPolicy($0) }) {
        self.model = model
        self.windows = windows
        self.setPolicy = setPolicy
        model.applyDockPresence = { [weak self] enabled in self?.transition(to: enabled) ?? false }
    }

    private func transition(to enabled: Bool) -> Bool {
        guard enabled != isEnabled else { return true }
        guard setPolicy(enabled ? .regular : .accessory) else { return false }
        isEnabled = enabled
        if enabled { windows.open("launcher") }
        else { windows.close("launcher") }
        return true
    }

    func reopen() {
        // The loaded preference performs the initial open if an event arrived during loading.
        guard !model.isLoading, isEnabled else { return }
        windows.open("launcher")
    }
}

/// Captures only the existing SwiftUI-owned window; never creates a second AppKit window.
struct LauncherWindowBridge: NSViewRepresentable {
    let windows: WindowActionRelay
    func makeNSView(context: Context) -> WindowProbe {
        WindowProbe(windows: windows)
    }
    func updateNSView(_ nsView: WindowProbe, context: Context) { }

    final class WindowProbe: NSView {
        let windows: WindowActionRelay
        init(windows: WindowActionRelay) { self.windows = windows; super.init(frame: .zero) }
        required init?(coder: NSCoder) { nil }
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let window { windows.registerLauncher(window) }
        }
    }
}
